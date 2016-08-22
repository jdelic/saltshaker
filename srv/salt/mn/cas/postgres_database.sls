
{% if pillar['casserver'].get('backend', '') == 'postgresql' %}

# only create this if the PostgreSQL backend is selected
casserver-postgres:
    postgres_database.present:
        - name: {{pillar['casserver']['dbname']}}
        - tablespace: secure
        - encoding: utf8  # postgresql spelling
        - owner: >
            {%- if pillar['casserver'].get('vault-manages-database', False) %}
                {{pillar['vault']['managed-database-owner']}}
            {%- else %}
                {{pillar['casserver']['dbuser']}}
            {%- endif %}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - secure-tablespace
{% endif %}
