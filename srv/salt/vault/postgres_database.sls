#
# Creates a PostgreSQL database for Hashicorp Vault (as a backend) and an associated user.
# This is *independent* from the Vault PostgreSQL secret backend that allows services to get
# temporary PostgreSQL access credentials.
#
# This state is meant to be run on a server with the "secure-database" role.
#

{% if pillar['vault'].get('backend', '') == 'postgresql' %}

# only create this if the MySQL backend is selected
vault-postgres:
    postgres_user.present:
        - name: {{pillar['vault']['postgres']['dbuser']}}
        - createdb: False
        - createroles: True
        - createuser: True
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicpasswords']['secure-vault']}}
        - user: postgres
    postgres_database.present:
        - name: vault
        - tablespace: secure
        - encoding: utf-8
        - owner: concourse
        - user: {{pillar['vault']['postgres']['dbuser']}}
        - require:
            - postgres_user: vault-postgres
{% endif %}
