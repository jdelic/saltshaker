#
# Creates a PostgreSQL database for Hashicorp Vault (as a backend) and an associated user.
# This is *independent* from the Vault PostgreSQL secret backend that allows services to get
# temporary PostgreSQL access credentials.
#
# This state is meant to be run on a server with the "secure-database" role.
#

{% if pillar['vault'].get('backend', '') == 'postgresql' %}

# only create this if the PostgreSQL backend is selected
vault-postgres:
    postgres_user.present:
        - name: {{pillar['vault']['postgres']['dbuser']}}
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicpasswords']['secure-vault']}}
        - user: postgres
        - require:
            - secure-tablespace
    postgres_database.present:
        - name: {{pillar['vault']['postgres']['dbname']}}
        - tablespace: secure
        - encoding: utf8  # postgresql spelling
        - owner: {{pillar['vault']['postgres']['dbuser']}}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: vault-postgres
            - secure-tablespace
    cmd.script:
        - name: salt://vault/vault_postgresql_db.jinja.sh
        - template: jinja
        - use_vt: True
        - onchanges:
            - postgres_database: vault-postgres
        - env:
            - PGPASSWORD: {{pillar['dynamicpasswords']['secure-vault']}}
        - require:
            - postgres_database: vault-postgres
{% endif %}
