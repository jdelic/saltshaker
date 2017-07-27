# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if AuthServer
# is not configured to use Vault.
{% if pillar.get('authserver', {}).get('use-vault', False) %}
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


authserver-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql/creds/authserver_fullaccess" {
                policy="read"
            }' | /usr/local/bin/vault policy-write postgresql_authserver_fullaccess -
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_fullaccess >/dev/null
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"


authserver-vault-postgresql-backend:
    cmd.run:
        - name: /usr/local/bin/vault mount -path=postgresql database
        - unless: /usr/local/bin/vault mounts | grep postgresql >/dev/null
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"


authserver-vault-postgresql-connection:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write postgresql/config/{{pillar['authserver']['dbname']}} \
                plugin_name=postgresql-database-plugin \
                allowed_roles="authserver_fullaccess" \
                connection_url="postgresql://{{pillar['authserver']['dbuser']}}:{{pillar['dynamicsecrets']['authserver']}}@postgresql.service.consul:5432/"
        - onchanges:
            - cmd: authserver-vault-postgresql-backend
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"


authserver-vault-postgresql-role:
    file.managed:
        - name: /etc/appconfig/authserver/vault_role.json
        - contents: |
            {
                "db_name": "{{pillar['authserver']['dbname']}}",
                "default_ttl": "10m",
                "max_ttl": "1h",
                "creation_statements": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '{{'{{'}}password{{'}}'}}' VALID UNTIL '{{'{{'}}expiration{{'}}'}}' IN ROLE \"{{pillar['authserver']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_statements": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }
        - require:
            - appconfig: authserver-appconfig
    cmd.run:
        - name: cat /etc/appconfig/authserver/vault_role.json | /usr/local/bin/vault write postgresql/roles/authserver_fullaccess -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: authserver-vault-postgresql-connection
        - require:
            - file: authserver-vault-postgresql-role
{% endif %}
