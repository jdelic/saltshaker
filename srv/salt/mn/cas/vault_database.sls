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
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"
        - onchanges:
            - cmd: vault-cert-auth-enabled


authserver-vault-postgresql-policy:
    cmd.run:
        - name: >-
            echo 'path "postgresql_authserver/creds/fullaccess" {
                policy="read"
            }' | /usr/local/bin/vault policy-write postgresql_authserver_fullaccess -
        - unless: /usr/local/bin/vault policies | grep postgresql_authserver_fullaccess >/dev/null
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"


authserver-vault-postgresql-backend:
    cmd.run:
        - name: /usr/local/bin/vault mount -path=postgresql_authserver postgresql
        - unless: /usr/local/bin/vault mounts | grep postgresql_authserver >/dev/null
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"


authserver-vault-postgresql-connection:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write postgresql_authserver/config/connection \
                connection_url="postgresql://{{pillar['authserver']['dbuser']}}:{{pillar['dynamicsecrets']['authserver']}}@postgresql.local:5432/{{pillar['authserver']['dbname']}}"
        - onchanges:
            - cmd: authserver-vault-postgresql-backend
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"

authserver-vault-postgresql-lease:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write postgresql_authserver/config/lease lease=10m lease_max=1h
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"
        - onchanges:
            - cmd: authserver-vault-postgresql-connection


authserver-vault-postgresql-role:
    file.managed:
        - name: /etc/appconfig/authserver/vault_role.json
        - contents: |
            {
                "sql": "CREATE ROLE \"{{'{{'}}name{{'}}'}}\" WITH LOGIN ENCRYPTED PASSWORD '{{'{{'}}password{{'}}'}}' VALID UNTIL '{{'{{'}}expiration{{'}}'}}' IN ROLE \"{{pillar['authserver']['dbuser']}}\" INHERIT NOCREATEROLE NOCREATEDB NOSUPERUSER NOREPLICATION NOBYPASSRLS;",
                "revocation_sql": "DROP ROLE \"{{'{{'}}name{{'}}'}}\";"
            }
    cmd.run:
        - name: cat /etc/appconfig/authserver/vault_role.json | /usr/local/bin/vault write postgresql_authserver/roles/fullaccess -
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"
        - onchanges:
            - cmd: authserver-vault-postgresql-connection
        - require:
            - file: authserver-vault-postgresql-role
{% endif %}
