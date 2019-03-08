# This state will create the user that OpenSMTPD can use to access authserver's stored procedure API.
# The privileges necessary to access the API are granted by a migration in authserver, since Salt
# does not control the table creation / database schema.

{% if pillar['authserver'].get('backend', '') == 'postgresql' %}
    {% for rolename in pillar['authserver']['stored-procedure-api-users'] %}

authserver-{{rolename}}-spapi-access:
    postgres_user.present:
            - name: {{rolename}}
            - createdb: False
            - createroles: False
            - encrypted: True
            - login: True
            - inherit: False
            - superuser: False
            - replication: False
            - password: {{pillar['dynamicsecrets'][rolename]}}
            - user: postgres
            - order: 20  # see ORDER.md
            - require:
                - service: data-cluster-service
                - postgres_database: authserver-postgres

    {% endfor %}
{% endif %}
