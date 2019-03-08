# create a user for checking the database

include:
    - postgresql.sync


checkuser-postgres:
    postgres_user.present:
        - name: checkuser
        - createdb: False
        - createroles: False
        - encrypted: True
        - login: True
        - inherit: True
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['checkuser']}}
        - user: postgres
        - require:
            - service: data-cluster-service
    # by default all users are allowed to create new tables in the 'public' schema in
    # a database. So we make sure to revoke that right, if we happen to have it because
    # the PostgreSQL server might not be hardened by using a database template that does
    # does not grant 'create' on the implicit 'public' schema.
    postgres_privileges.present:
        - name: checkuser
        - object_name: postgres
        - object_type: database
        - privileges:
            - CONNECT
        - user: postgres
        - maintenance_db: postgres
        - require:
            - postgres_user: checkuser-postgres


checkuser-drop-create:
    postgres_privileges.absent:
        - name: checkuser
        - object_name: public
        - object_type: schema
        - privileges:
            - CREATE
        - user: postgres
        - maintenance_db: postgres
        - require:
            - postgres_user: checkuser-postgres
        - require_in:
            - cmd: postgresql-sync


checkuser-pgbha-md5:
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: postgres checkuser
        - require_in:
            - file: postgresql-hba-config
