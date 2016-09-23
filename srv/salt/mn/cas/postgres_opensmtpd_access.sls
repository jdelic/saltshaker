# This state will create the user that OpenSMTPD can use to access authserver's stored procedure API.
# The privileges necessary to access the API are granted by a migration in authserver, since Salt
# does not control the table creation / database schema.

{% if pillar['authserver'].get('backend', '') == 'postgresql' %}

authserver-opensmtpd-access:
    postgres_user.present:
            - name: {{pillar['authserver']['opensmtpd-dbuser']}}
            - createdb: False
            - createroles: False
            - createuser: False
            - encrypted: True
            - login: True
            - inherit: False
            - superuser: False
            - replication: False
            - password: {{pillar['dynamicpasswords']['opensmtpd-authserver']}}
            - user: postgres
            - require:
                - service: data-cluster-service
                - postgres_database: authserver-postgres

{% endif %}
