# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if AuthServer
# is not configured to use Vault.
{% if pillar.get('authserver', {}).get('use-vault', False) %}
    {% if pillar.get('authserver', {}).get('vault-authtype', 'approle') == 'approle' %}
authserver-vault-approle:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/authserver \
                role_name=authserver \
                policies=postgresql_authserver_fullaccess \
                secret_id_num_uses=0 \
                secret_id_ttl=0 \
                period=24h \
                token_ttl=0 \
                token_max_ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: vault-approle-auth-enabled


authserver-vault-approle-roleid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/authserver/role-id \
                role_id="{{pillar['dynamicsecrets']['authserver-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: authserver-vault-approle

    {% elif pillar.get('authserver', {}).get('vault-authtype', 'approle') == 'ssl' %}

authserver-vault-ssl-cert:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/cert/certs/authserver_database \
                display_name="authserver" \
                policies=postgresql_authserver_fullaccess \
                certificate=@{{pillar['authserver']['vault-application-ca']}} \
                ttl=3600
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/cert/certs | grep authserver_database >/dev/null
        - onlyif: /usr/local/bin/vault init -check >/dev/null
        - onchanges:
            - cmd: vault-cert-auth-enabled
    {% endif %}


authserver-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql/creds/authserver_fullaccess" {
                capabilities = ["read"]
            }' | /usr/local/bin/vault policy-write postgresql_authserver_fullaccess -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_fullaccess >/dev/null
        - onlyif: /usr/local/bin/vault init -check >/dev/null


authserver-vault-postgresql-backend:
    cmd.run:
        - name: /usr/local/bin/vault mount -path=postgresql database
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault mounts | grep postgresql >/dev/null
        - onlyif: /usr/local/bin/vault init -check >/dev/null


authserver-vault-postgresql-connection:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write postgresql/config/{{pillar['authserver']['dbname']}} \
                plugin_name=postgresql-database-plugin \
                allowed_roles="authserver_fullaccess,authserver_mailforwarder,authserver_dkimsigner" \
                connection_url="postgresql://{{pillar['authserver']['dbuser']}}:{{pillar['dynamicsecrets']['authserver']}}@postgresql.service.consul:5432/"
        - onlyif: /usr/local/bin/vault init -check >/dev/null
        - onchanges:
            - cmd: authserver-vault-postgresql-backend
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"


authserver-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '{{'{{'}}password{{'}}'}}' VALID UNTIL '{{'{{'}}expiration{{'}}'}}' IN ROLE \"{{pillar['authserver']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_fullaccess -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault init -check >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_fullaccess >/dev/null
        - onchanges:
            - cmd: authserver-vault-postgresql-connection


mailforwarder-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '{{'{{'}}password{{'}}'}}' VALID UNTIL '{{'{{'}}expiration{{'}}'}}' IN ROLE \"{{pillar['mailforwarder']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_mailforwarder -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault init -check >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_mailforwarder >/dev/null
        - onchanges:
            - cmd: mailforwarder-vault-postgresql-connection


dkimsigner-vault-postgresql-role:
    cmd.run:
        - name: >-
            echo '{
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '{{'{{'}}password{{'}}'}}' VALID UNTIL '{{'{{'}}expiration{{'}}'}}' IN ROLE \"{{pillar['dkimsigner']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }' | /usr/local/bin/vault write postgresql/roles/authserver_dkimsigner -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onlyif: /usr/local/bin/vault init -check >/dev/null
        - unless: /usr/local/bin/vault list postgresql/roles | grep authserver_dkimsigner >/dev/null
        - onchanges:
            - cmd: dkimsigner-vault-postgresql-connection
{% endif %}
