
{% if pillar['authserver'].get('backend', '') == 'postgresql' %}

# only create this if the PostgreSQL backend is selected
authserver-postgres:
    postgres_user.present:
        - name: {{pillar['authserver']['dbuser']}}
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: True
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['authserver']}}
        - user: postgres
        - require:
            - service: data-cluster-service
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
    postgres_database.present:
        - name: {{pillar['authserver']['dbname']}}
        - tablespace: secure
        - encoding: utf8  # postgresql spelling
        - owner: {{pillar['authserver']['dbuser']}}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - secure-tablespace
            - postgres_user: authserver-postgres


dkimsigner-postgres:
    postgres_user.present:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: True
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['dkimsigner']}}
        - user: postgres
        - require:
            - service: data-cluster-service
    # by default all users are allowed to create new tables in the 'public' schema in
    # a database. So we make sure to revoke that right, if we happen to have it because
    # the PostgreSQL server might not be hardened by using a database template that does
    # does not grant 'create' on the implicit 'public' schema.
    postgres_privileges.present:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - object_name: {{pillar['authserver']['dbname']}}
        - object_type: database
        - privileges:
            - CONNECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: dkimsigner-postgres


dkimsigner-drop-create:
    postgres_privileges.absent:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - object_name: public
        - object_type: schema
        - privileges:
            - CREATE
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: dkimsigner-postgres


dkimsigner-usage-privileges:
    postgres_privileges.present:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - object_name: public
        - object_type: schema
        - privileges:
            - USAGE
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: dkimsigner-postgres


dkimsigner-read-privileges:
    postgres_privileges.present:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - object_name: mailauth_domain
        - object_type: table
        - privileges:
            - SELECT
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: dkimsigner-postgres


authserver-vault-md5:
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config


authserver-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config


dkimsigner-vault-md5:
  file.accumulated:
      - name: postgresql-hba-md5users-accumulator
      - filename: {{pillar['postgresql']['hbafile']}}
      - text: {{pillar['authserver']['dbname']}} {{pillar['dkimsigner']['dbuser']}}
      - require_in:
          - file: postgresql-hba-config


dkimsigner-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['dkimsigner']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
{% endif %}
