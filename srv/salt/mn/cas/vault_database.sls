# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if AuthServer
# is not configured to use Vault.

include:
    - mn.cas.sync
    - vault.sync


{% if pillar.get('authserver', {}).get('use-vault', False) %}
    {% if pillar.get('authserver', {}).get('vault-authtype', 'approle') == 'approle' %}
authserver-vault-approle:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/authserver \
                role_name=authserver \
                policies=postgresql_authserver_fullaccess,authserver_oauth2_write \
                secret_id_num_uses=0 \
                secret_id_ttl=0 \
                period=24h \
                token_ttl=0 \
                token_max_ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/approle/role | grep authserver >/dev/null
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


authserver-vault-approle-roleid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/authserver/role-id \
                role_id="{{pillar['dynamicsecrets']['authserver-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: authserver-vault-approle
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


authserver-vault-no-cert:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/cert/certs/authserver_database
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/cert/certs | grep authserver_database >/dev/null
        - require:
            - cmd: vault-sync

    {% elif pillar.get('authserver', {}).get('vault-authtype', 'approle') == 'cert' %}

authserver-vault-ssl-cert:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/cert/certs/authserver_database \
                display_name="authserver" \
                policies=postgresql_authserver_fullaccess,authserver_oauth2_write \
                certificate=@{{pillar['authserver']['vault-application-ca']}} \
                allowed_names="authserver" \
                ttl=3600
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/cert/certs | grep authserver_database >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


authserver-vault-no-approle:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/approle/role/authserver
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/approle/role | grep authserver >/dev/null
        - require:
            - cmd: vault-sync
    {% endif %}


    {% if pillar.get('mailforwarder', {}).get('vault-authtype', 'approle') == 'approle' %}
mailforwarder-vault-approle:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/mailforwarder \
                role_name=mailforwarder \
                policies=postgresql_authserver_mailforwarder \
                secret_id_num_uses=0 \
                secret_id_ttl=0 \
                period=24h \
                token_ttl=0 \
                token_max_ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/approle/role | grep mailforwarder >/dev/null
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


mailforwarder-vault-approle-roleid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/mailforwarder/role-id \
                role_id="{{pillar['dynamicsecrets']['mailforwarder-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: mailforwarder-vault-approle
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


mailforwarder-vault-no-cert:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/cert/certs/mailforwarder_database
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/cert/certs | grep mailforwarder_database >/dev/null
        - require:
            - cmd: vault-sync

    {% elif pillar.get('mailforwarder', {}).get('vault-authtype', 'approle') == 'cert' %}

mailforwarder-vault-ssl-cert:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/cert/certs/mailforwarder_database \
                display_name="mailforwarder" \
                policies=postgresql_authserver_mailforwarder \
                certificate=@{{pillar['authserver']['vault-application-ca']}} \
                allowed_names="mailforwarder" \
                ttl=3600
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/cert/certs | grep mailforwarder_database >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


mailforwarder-vault-no-approle:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/approle/role/mailforwarder
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/approle/role | grep mailforwarder >/dev/null
        - require:
            - cmd: vault-sync
    {% endif %}


    {% if pillar.get('mailforwarder', {}).get('vault-authtype', 'approle') == 'approle' %}
dkimsigner-vault-approle:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/dkimsigner \
                role_name=dkimsigner \
                policies=postgresql_authserver_dkimsigner \
                secret_id_num_uses=0 \
                secret_id_ttl=0 \
                period=24h \
                token_ttl=0 \
                token_max_ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/approle/role | grep dkimsigner >/dev/null
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


dkimsigner-vault-approle-roleid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/dkimsigner/role-id \
                role_id="{{pillar['dynamicsecrets']['dkimsigner-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: dkimsigner-vault-approle
        - require_in:
            - cmd: authserver-sync-vault
        - require:
            - cmd: vault-sync


dkimsigner-vault-no-cert:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/cert/certs/dkimsigner_database
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/cert/certs | grep dkimsigner_database >/dev/null
        - require:
            - cmd: vault-sync
    {% elif pillar.get('mailforwarder', {}).get('vault-authtype', 'approle') == 'cert' %}

dkimsigner-vault-ssl-cert:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/cert/certs/dkimsigner_database \
                display_name="dkimsigner" \
                policies=postgresql_authserver_dkimsigner \
                certificate=@{{pillar['authserver']['vault-application-ca']}} \
                allowed_names="dkimsigner" \
                ttl=3600
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/cert/certs | grep dkimsigner_database >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


dkimsigner-vault-no-approle:
    cmd.run:
        - name: /usr/local/bin/vault delete auth/approle/role/dkimsigner
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null && /usr/local/bin/vault list auth/approle/role | grep dkimsigner >/dev/null
        - require:
            - cmd: vault-sync
    {% endif %}


authserver-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql/creds/authserver_fullaccess" {
                capabilities = ["read"]
            }' | /usr/local/bin/vault policy write postgresql_authserver_fullaccess -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_fullaccess >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: authserver-sync-vault


authserver-vault-oauth2-write-policy:
    cmd.run:
        - name: >-
            echo 'path "secret/oauth2/*" {
                capabilities = ["create", "read", "list", "delete", "update"]
            }' | /usr/local/bin/vault policy write authserver_oauth2_write -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep authserver_oauth2_write >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: authserver-sync-vault


mailforwarder-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql/creds/authserver_mailforwarder" {
                capabilities = ["read"]
            }' | /usr/local/bin/vault policy write postgresql_authserver_mailforwarder -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_mailforwarder >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


dkimsigner-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql/creds/authserver_dkimsigner" {
                capabilities = ["read"]
            }' | /usr/local/bin/vault policy write postgresql_authserver_dkimsigner -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_dkimsigner >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


authserver-vault-postgresql-backend:
    cmd.run:
        - name: /usr/local/bin/vault secrets enable -path=postgresql database
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault secrets list | grep postgresql >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: authserver-sync-vault


authserver-vault-postgresql-connection:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write postgresql/config/{{pillar['authserver']['dbname']}} \
                plugin_name=postgresql-database-plugin \
                allowed_roles="authserver_fullaccess,authserver_mailforwarder,authserver_dkimsigner" \
                connection_url="postgresql://{{pillar['authserver']['dbuser']}}:{{pillar['dynamicsecrets']['authserver']}}@postgresql.service.consul:5432/?sslmode=verify-full"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - unless: /usr/local/bin/vault list postgresql/config | grep authserver >/dev/null
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - cmd: vault-sync
            - cmd: authserver-vault-postgresql-backend
        - require_in:
            - cmd: authserver-sync-vault


# '"'"' is bash for ' when using single quotes around the json string
authserver-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '"'"'{{'{{'}}password{{'}}'}}'"'"' VALID UNTIL '"'"'{{'{{'}}expiration{{'}}'}}'"'"' IN ROLE \"{{pillar['authserver']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_fullaccess -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_fullaccess >/dev/null
        - require:
            - cmd: vault-sync
            - cmd: authserver-vault-postgresql-backend
        - require_in:
            - cmd: authserver-sync-vault


mailforwarder-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '"'"'{{'{{'}}password{{'}}'}}'"'"' VALID UNTIL '"'"'{{'{{'}}expiration{{'}}'}}'"'"' IN ROLE \"{{pillar['mailforwarder']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_mailforwarder -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_mailforwarder >/dev/null
        - require:
            - cmd: vault-sync


dkimsigner-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '"'"'{{'{{'}}password{{'}}'}}'"'"' VALID UNTIL '"'"'{{'{{'}}expiration{{'}}'}}'"'"' IN ROLE \"{{pillar['dkimsigner']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_dkimsigner -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_dkimsigner >/dev/null
        - require:
            - cmd: vault-sync
{% endif %}
