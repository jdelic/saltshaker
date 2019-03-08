
{% if pillar['authserver'].get('backend', '') == 'postgresql' %}

include:
    - postgresql.sync


# only create this if the PostgreSQL backend is selected
authserver-postgres:
    postgres_user.present:
        - name: {{pillar['authserver']['dbuser']}}
        - createdb: False
{% if pillar['authserver'].get('use-vault', False) %}
        - createroles: True
{% else %}
        - createroles: False
{% endif %}
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
            - cmd: postgresql-sync
            - postgres_user: authserver-postgres


{% for user in ['dkimsigner', 'mailforwarder'] %}
{{user}}-postgres:
    postgres_user.present:
        - name: {{pillar[user]['dbuser']}}
        - createdb: False
{% if pillar[user].get('use-vault', False) %}
        - createroles: False
{% else %}
        - createroles: True
{% endif %}
        - encrypted: True
        - login: True
        - inherit: True
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets'][user]}}
        - user: postgres
        - require:
            - cmd: postgresql-sync
    # by default all users are allowed to create new tables in the 'public' schema in
    # a database. So we make sure to revoke that right, if we happen to have it because
    # the PostgreSQL server might not be hardened by using a database template that does
    # does not grant 'create' on the implicit 'public' schema.
    postgres_privileges.present:
        - name: {{pillar[user]['dbuser']}}
        - object_name: {{pillar['authserver']['dbname']}}
        - object_type: database
        - privileges:
            - CONNECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: {{user}}-postgres


{{user}}-drop-create:
    postgres_privileges.absent:
        - name: {{pillar[user]['dbuser']}}
        - object_name: public
        - object_type: schema
        - privileges:
            - CREATE
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: {{user}}-postgres


{{user}}-usage-privileges:
    postgres_privileges.present:
        - name: {{pillar[user]['dbuser']}}
        - object_name: public
        - object_type: schema
        - privileges:
            - USAGE
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - require:
            - postgres_user: {{user}}-postgres
{% endfor %}


dkimsigner-read-privileges:
    postgres_privileges.present:
        - name: {{pillar['dkimsigner']['dbuser']}}
        - object_name: mailauth_domain
        - object_type: table
        - privileges:
            - SELECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - order: last  # make sure this is ordered after authserver setup, when the database table exists


mailforwarder-read-privileges-emailalias:
    postgres_privileges.present:
        - name: {{pillar['mailforwarder']['dbuser']}}
        - object_name: mailauth_emailalias
        - object_type: table
        - privileges:
            - SELECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - order: last  # make sure this is ordered after authserver setup, when the database table exists


mailforwarder-read-privileges-mnuser:
    postgres_privileges.present:
        - name: {{pillar['mailforwarder']['dbuser']}}
        - object_name: mailauth_mnuser
        - object_type: table
        - privileges:
            - SELECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - order: last  # make sure this is ordered after authserver setup, when the database table exists


mailforwarder-read-privileges-domain:
    postgres_privileges.present:
        - name: {{pillar['mailforwarder']['dbuser']}}
        - object_name: mailauth_domain
        - object_type: table
        - privileges:
            - SELECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - order: last  # make sure this is ordered after authserver setup, when the database table exists


mailforwarder-read-privileges-mailinglist:
    postgres_privileges.present:
        - name: {{pillar['mailforwarder']['dbuser']}}
        - object_name: mailauth_mailinglist
        - object_type: table
        - privileges:
            - SELECT
        - user: postgres
        - maintenance_db: {{pillar['authserver']['dbname']}}
        - order: last  # make sure this is ordered after authserver setup, when the database table exists


{% if pillar['authserver'].get('use-vault', False) %}
authserver-vault-md5:
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
{% else %}
authserver-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
{% endif %}


{% if pillar['dkimsigner'].get('use-vault', False) %}
dkimsigner-vault-md5:
  file.accumulated:
      - name: postgresql-hba-md5users-accumulator
      - filename: {{pillar['postgresql']['hbafile']}}
      - text: {{pillar['authserver']['dbname']}} {{pillar['dkimsigner']['dbuser']}}
      - require_in:
          - file: postgresql-hba-config
{% else %}
dkimsigner-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['dkimsigner']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
{% endif %}


{% if pillar['mailforwarder'].get('use-vault', False) %}
mailforwarder-vault-md5:
  file.accumulated:
      - name: postgresql-hba-md5users-accumulator
      - filename: {{pillar['postgresql']['hbafile']}}
      - text: {{pillar['authserver']['dbname']}} {{pillar['mailforwarder']['dbuser']}}
      - require_in:
          - file: postgresql-hba-config
{% else %}
mailforwarder-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['mailforwarder']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
{% endif %}

{% endif %}
