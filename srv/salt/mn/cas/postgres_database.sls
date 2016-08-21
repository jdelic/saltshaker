
{% if pillar['casserver'].get('backend', '') == 'postgresql' %}

# only create this if the MySQL backend is selected
casserver-postgres:
    postgres_user.present:
        - name: {{pillar['casserver']['dbuser']}}
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicpasswords'][pillar['casserver']['dbuser']]}}
        - user: postgres
        - require:
            - secure-tablespace
    postgres_database.present:
        - name: {{pillar['casserver']['dbname']}}
        - tablespace: secure
        - encoding: utf8  # postgresql spelling
        - owner: {{pillar['casserver']['dbuser']}}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: casserver-postgres
            - secure-tablespace
{% endif %}
