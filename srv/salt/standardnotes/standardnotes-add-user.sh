#!/usr/bin/env bash

set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" != "" ]; then
    echo "usage: standardnotes-add-user <email>" >&2
    exit 1
fi

EMAIL="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
if ! printf '%s\n' "$EMAIL" | grep -Eq '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'; then
    echo "invalid email address: $EMAIL" >&2
    exit 1
fi

ENV_FILE="/etc/standardnotes/.env"
if [ ! -r "$ENV_FILE" ]; then
    echo "cannot read $ENV_FILE" >&2
    exit 1
fi

env_value() {
    local key="$1"
    sed -n "s/^${key}=//p" "$ENV_FILE" | head -n 1
}

DB_NAME="$(env_value DB_DATABASE)"
DB_USER="$(env_value DB_USERNAME)"
DB_PASSWORD="$(env_value DB_PASSWORD)"

for var_name in DB_NAME DB_USER DB_PASSWORD; do
    if [ -z "${!var_name}" ]; then
        echo "missing ${var_name} in $ENV_FILE" >&2
        exit 1
    fi
done

PASSWORD=""
while [ "${#PASSWORD}" -lt 24 ]; do
    PASSWORD="$(head -c 64 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 24)"
done

USER_UUID="$(cat /proc/sys/kernel/random/uuid)"
PW_NONCE="$(openssl rand -hex 32)"
KP_CREATED="$(date +%s%3N)"
NOW_UTC="$(date -u '+%Y-%m-%d %H:%M:%S')"

derive_server_password() {
    local identifier="$1"
    local seed="$2"
    local passphrase="$3"

    SN_IDENTIFIER="$identifier" SN_SEED="$seed" SN_PASSPHRASE="$passphrase" python3 - <<'PY'
import hashlib
import os
import sys

identifier = os.environ["SN_IDENTIFIER"]
seed = os.environ["SN_SEED"]
passphrase = os.environ["SN_PASSPHRASE"].encode("utf-8")
salt = bytes.fromhex(hashlib.sha256(f"{identifier}:{seed}".encode("utf-8")).hexdigest()[:32])

derived = None

try:
    from nacl.bindings import crypto_pwhash

    derived = crypto_pwhash.crypto_pwhash_alg(
        outlen=64,
        passwd=passphrase,
        salt=salt,
        opslimit=5,
        memlimit=67108864,
        alg=crypto_pwhash.crypto_pwhash_ALG_DEFAULT,
    )
except ModuleNotFoundError:
    pass
except Exception:
    pass

if derived is None:
    try:
        from argon2.low_level import Type, hash_secret_raw

        derived = hash_secret_raw(
            passphrase,
            salt,
            time_cost=5,
            memory_cost=65536,
            parallelism=1,
            hash_len=64,
            type=Type.ID,
        )
    except ModuleNotFoundError:
        sys.exit(3)

derived_hex = derived.hex()
server_password = derived_hex[len(derived_hex) // 2 :]
sys.stdout.write(server_password)
PY
}

if ! SERVER_PASSWORD="$(derive_server_password "$EMAIL" "$PW_NONCE" "$PASSWORD")"; then
    echo "could not derive Standard Notes server password; install python3-nacl or python3-argon2" >&2
    exit 1
fi

hash_password() {
    local password_to_hash="$1"
    SN_PASSWORD="$password_to_hash" python3 - <<'PY'
import os
import sys

try:
    import bcrypt
except ModuleNotFoundError:
    sys.exit(2)

password = os.environ["SN_PASSWORD"].encode("utf-8")
hashed = bcrypt.hashpw(password, bcrypt.gensalt(rounds=11))
sys.stdout.write(hashed.decode("utf-8"))
PY
}

if ! PASSWORD_HASH="$(hash_password "$SERVER_PASSWORD")"; then
    echo "could not create password hash with python3-bcrypt" >&2
    exit 1
fi

sql_escape() {
    printf '%s' "$1" | sed "s/'/''/g"
}

mysql_scalar() {
    local query="$1"
    docker exec \
        -e MYSQL_PWD="$DB_PASSWORD" \
        standardnotes_db \
        mysql -Nse "$query" -u"$DB_USER" "$DB_NAME"
}

ROLE_UUID="$(mysql_scalar "SELECT uuid FROM roles WHERE name='CORE_USER' LIMIT 1" | tr -d '[:space:]')"

if [ -z "$ROLE_UUID" ]; then
    echo "could not find CORE_USER role in database" >&2
    exit 1
fi

EMAIL_SQL="$(sql_escape "$EMAIL")"
USER_UUID_SQL="$(sql_escape "$USER_UUID")"
PW_NONCE_SQL="$(sql_escape "$PW_NONCE")"
KP_CREATED_SQL="$(sql_escape "$KP_CREATED")"
NOW_UTC_SQL="$(sql_escape "$NOW_UTC")"
PASSWORD_HASH_SQL="$(sql_escape "$PASSWORD_HASH")"
ROLE_UUID_SQL="$(sql_escape "$ROLE_UUID")"

EXISTING_COUNT="$(mysql_scalar "SELECT COUNT(*) FROM users WHERE email='${EMAIL_SQL}'" | tr -d '[:space:]')"

if [ "$EXISTING_COUNT" != "0" ]; then
    echo "user already exists: $EMAIL" >&2
    exit 1
fi

docker exec \
    -i \
    -e MYSQL_PWD="$DB_PASSWORD" \
    standardnotes_db \
    mysql -u"$DB_USER" "$DB_NAME" <<SQL
START TRANSACTION;
INSERT INTO users (
    uuid, version, email, pw_nonce, kp_created, kp_origination,
    encrypted_password, encrypted_server_key, server_encryption_version,
    created_at, updated_at, locked_until, num_failed_attempts
) VALUES (
    '${USER_UUID_SQL}', '004', '${EMAIL_SQL}', '${PW_NONCE_SQL}', '${KP_CREATED_SQL}', 'registration',
    '${PASSWORD_HASH_SQL}', NULL, 0,
    '${NOW_UTC_SQL}', '${NOW_UTC_SQL}', NULL, 0
);
INSERT INTO user_roles (user_uuid, role_uuid) VALUES ('${USER_UUID_SQL}', '${ROLE_UUID_SQL}');
COMMIT;
SQL

printf 'username: %s\npassword: %s\n' "$EMAIL" "$PASSWORD"
