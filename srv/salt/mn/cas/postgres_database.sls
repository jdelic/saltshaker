
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
        - require_in:
            - service: authserver  # make sure the database and user exist when we start the server


authserver-vault-md5:
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
            - service: authserver  # make sure the server can authenticate when it's started


authserver-sslclient:
    file.accumulated:
        - name: postgresql-hba-certusers-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['authserver']['dbname']}} {{pillar['authserver']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
            - service: authserver  # make sure the server can authenticate when it's started
{% endif %}
