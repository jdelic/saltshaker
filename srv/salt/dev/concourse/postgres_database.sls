
# this state should be run on a server role with postgressql.fast

include:
    - postgresql.sync


concourse-db-role:
    postgres_user.present:
        - name: concourse
        - password: {{pillar['dynamicsecrets']['concourse-db']}}
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
        - text: concourse concourse
        - require_in:
            - file: postgresql-hba-config


concourse-db:
    postgres_database.present:
        - name: concourse
        - encoding: utf8  # postgresql spelling
        - owner: concourse
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: concourse-db-role
    postgres_privileges.present:
        - name: concourse
        - object_name: public
        - object_type: schema
        - privileges:
            - CREATE
        - user: postgres
        - maintenance_db: concourse
        - require:
            - postgres_database: concourse
