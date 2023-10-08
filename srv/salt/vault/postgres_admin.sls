# creates a vaultadmin role that can be used to create dynamic credentials
# from the Vault postgresql secret backend

include:
    - postgresql.sync
    - vault.sync


vaultadmin:
    postgres_user.present:
        - name: {{pillar['vault']['managed-database-owner']}}
        - createdb: False
        - createroles: True
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['vault-db-credential-admin']}}
        - user: postgres
        - require_in:
            - cmd: vault-database-sync
        - require:
            - cmd: postgresql-sync

# vim: syntax=yaml
