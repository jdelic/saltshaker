# this state should be run on a server role with postgressql.secure

include:
    - postgresql.sync
    - vaultwarden.sync

{% if pillar['vaultwarden'].get('enabled', False) %}

vaultwarden-db-role:
    postgres_user.present:
        - name: vaultwarden
        - password: {{pillar['dynamicsecrets']['vaultwarden-db']}}
        - createdb: False
        - createroles: False
        - encrypted: scram-sha-256
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - user: postgres
        - require:
            - cmd: postgresql-sync
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: vaultwarden vaultwarden
        - require_in:
            - file: postgresql-hba-config


vaultwarden-db:
    postgres_database.present:
        - name: vaultwarden
        - encoding: utf8  # postgresql spelling
        - owner: vaultwarden
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: vaultwarden-db-role
        - require_in:
            - cmd: vaultwarden-sync-postgres

{% endif %}