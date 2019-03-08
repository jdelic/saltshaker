# creates a vaultadmin role that can be used to create dynamic credentials
# from the Vault postgresql secret backend

{% if pillar['vault'].get('backend', '') == 'postgresql' and
      pillar['vault'].get('create-database', False) %}

include:
    - postgresql.sync


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
        - require:
            - cmd: postgresql-sync
{% endif %}

# vim: syntax=yaml
