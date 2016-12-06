# creates a vaultadmin role that can be used to create dynamic credentials
# from the Vault postgresql secret backend

vaultadmin:
    postgres_user.present:
        - name: {{pillar['vault']['managed-database-owner']}}
        - createdb: False
        - createroles: True
        - createuser: True
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['vault-db-credential-admin']}}
        - user: postgres
        - require:
            - service: data-cluster-service


# vim: syntax=yaml
