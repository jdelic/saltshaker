#!/usr/bin/env bash

set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" != "" ]; then
    echo "usage: standardnotes-add-user <email>" >&2
    exit 1
fi

EMAIL="$1"
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

hash_password() {
    local password="$1"
    SN_PASSWORD="$password" python3 - <<'PY'
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

if ! PASSWORD_HASH="$(hash_password "$PASSWORD")"; then
    echo "could not create password hash with python3-bcrypt" >&2
    exit 1
fi

ROLE_UUID="$(docker exec \
    -e DB_NAME="$DB_NAME" \
    -e DB_USER="$DB_USER" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    standardnotes_db sh -lc 'mysql -Nse "SELECT uuid FROM roles WHERE name='\''CORE_USER'\'' LIMIT 1" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"')"

if [ -z "$ROLE_UUID" ]; then
    echo "could not find CORE_USER role in database" >&2
    exit 1
fi

EXISTING_COUNT="$(docker exec \
    -e DB_NAME="$DB_NAME" \
    -e DB_USER="$DB_USER" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    -e USER_EMAIL="$EMAIL" \
    standardnotes_db sh -lc 'mysql -Nse "SELECT COUNT(*) FROM users WHERE email='\''$USER_EMAIL'\''" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"')"

if [ "$EXISTING_COUNT" != "0" ]; then
    echo "user already exists: $EMAIL" >&2
    exit 1
fi

docker exec \
    -e DB_NAME="$DB_NAME" \
    -e DB_USER="$DB_USER" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    -e USER_UUID="$USER_UUID" \
    -e USER_EMAIL="$EMAIL" \
    -e PASSWORD_HASH="$PASSWORD_HASH" \
    -e PW_NONCE="$PW_NONCE" \
    -e KP_CREATED="$KP_CREATED" \
    -e NOW_UTC="$NOW_UTC" \
    -e ROLE_UUID="$ROLE_UUID" \
    standardnotes_db sh -lc '
mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<SQL
START TRANSACTION;
INSERT INTO users (
    uuid, version, email, pw_nonce, kp_created, kp_origination,
    encrypted_password, encrypted_server_key, server_encryption_version,
    created_at, updated_at, locked_until, num_failed_attempts
) VALUES (
    '$USER_UUID', '004', '$USER_EMAIL', '$PW_NONCE', '$KP_CREATED', 'registration',
    '$PASSWORD_HASH', NULL, 0,
    '$NOW_UTC', '$NOW_UTC', NULL, 0
);
INSERT INTO user_roles (user_uuid, role_uuid) VALUES ('$USER_UUID', '$ROLE_UUID');
COMMIT;
SQL
'

printf 'username: %s\npassword: %s\n' "$EMAIL" "$PASSWORD"
