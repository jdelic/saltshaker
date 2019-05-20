#
# Creates a PostgreSQL database for Hashicorp Vault (as a backend) and an associated user.
# This is *independent* from the Vault PostgreSQL secret backend that allows services to get
# temporary PostgreSQL access credentials.
#
# This state is meant to be run on a server with the "secure-database" role, so it can connect
# directly, side-stepping smartstack.
#

{% if pillar['vault'].get('backend', '') == 'postgresql' and
      pillar['vault'].get('create-database', False) %}

include:
    - postgresql.sync
    - consul.sync
    - powerdns.sync


# only create this if the PostgreSQL backend is selected
vault-postgres:
    postgres_user.present:
        - name: {{pillar['vault']['postgres']['dbuser']}}
        - createdb: False
        - createroles: False
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{pillar['dynamicsecrets']['secure-vault']}}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - cmd: postgresql-sync
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['vault']['postgres']['dbname']}} {{pillar['vault']['postgres']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
    postgres_database.present:
        - name: {{pillar['vault']['postgres']['dbname']}}
        - tablespace: secure
        - encoding: utf8  # postgresql spelling
        - owner: {{pillar['vault']['postgres']['dbuser']}}
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: vault-postgres
    cmd.script:
        - name: salt://vault/vault_postgresql_db.jinja.sh
        - template: jinja
        - context:
            user: {{pillar['vault']['postgres']['dbuser']}}
            db: {{pillar['vault']['postgres']['dbname']}}
            ip: {{pillar.get('postgresql', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('postgresql', {}).get('bind-port', 5432)}}
        - use_vt: True
        - order: 20  # see ORDER.md
        - onchanges:
            - postgres_database: vault-postgres
        - env:
            - PGPASSWORD: {{pillar['dynamicsecrets']['secure-vault']}}
        - require:
            - postgres_database: vault-postgres
        - require_in:
            - cmd: vault-sync-database


vault-postgres-ready:
    cmd.run:
        - name: >
            until host postgresql.service.consul || test ${count} -gt 30; do sleep 1; count=$((count+1)); done &&
            test ${count} -lt 30
        - env:
            count: 0
        - require_in:
            - cmd: vault-sync-database
        - require:
            - cmd: vault-postgres
            - cmd: consul-sync
            - cmd: powerdns-sync
{% endif %}
