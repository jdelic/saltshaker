# setting create_main_cluster = false in postgresql-common will prevent the automativ
# creation of a postgres cluster when we install the database

include:
    - postgresql.sync

{% set postgres_version = pillar.get('postgresql', {}).get('version', '11') %}
{% set port = pillar.get('postgresql', {}).get('bind-port', '5432') %}
{% set ip = pillar.get('postgresql', {}).get(
              'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                  'internal-ip-index', 0
              )|int()]
            ) %}


postgresql-repo:
    pkgrepo.managed:
        - humanname: PostgreSQL official repos
        - name: {{pillar["repos"]["postgresql"]}}
        - file: /etc/apt/sources.list.d/postgresql.list
        - key_url: salt://postgresql/postgresql_44A07FCC7D46ACCC4CF8.pgp.key


postgresql-step1:
    pkg.installed:
        - name: postgresql-common
        - fromrepo: stretch-pgdg
        - require:
            - pkgrepo: postgresql-repo
        - install_recommends: False
    file.managed:
        - name: /etc/postgresql-common/createcluster.conf
        - source: salt://postgresql/createcluster.conf
        - require:
            - pkg: postgresql-step1


data-base-dir:
    file.directory:
        - name: /data/postgres
        - user: postgres
        - group: postgres
        - mode: '0750'
        - require:
            - data-mount


postgresql-step2:
    pkg.installed:
        - pkgs:
            - postgresql
            - postgresql-{{postgres_version}}
            - postgresql-client-{{postgres_version}}
            - libpq5
        - install_recommends: False
        - fromrepo: stretch-pgdg
        - require:
            - postgresql-step1


data-cluster:
    cmd.run:
        - name: >
            /usr/bin/pg_createcluster -d /data/postgres/{{postgres_version}}/main --locale=en_US.utf-8 -e utf-8
            -p {{port}}
            {{postgres_version}} main
        - runas: root
        - unless: test -e /data/postgres/{{postgres_version}}/main
        - require:
            - postgresql-step2
            - data-base-dir


postgresql-hba-config:
    file.managed:
        - name: /etc/postgresql/{{postgres_version}}/main/{{pillar['postgresql']['hbafile']}}
        - source: salt://postgresql/pg_hba.jinja.conf
        - template: jinja
        - require:
            - cmd: data-cluster


data-cluster-config-base:
    file.append:
        - name: /etc/postgresql/{{postgres_version}}/main/postgresql.conf
        - text: |
            listen_addresses = '{{ip}}'
            max_wal_senders = 2  # minimum necessary for for hot backup without additional log shipping
            wal_keep_segments = 3  # just as a precaution.
            wal_level = replica
            archive_mode = off  # we don't do log shipping, just hot backups, so we don't need archive_command
        - require:
            - cmd: data-cluster
        - require_in:
            - file: postgresql-hba-config


{% if pillar.get("ssl", {}).get("postgresql") %}
postgresql-ssl-cert:
    file.managed:
        - name: {{pillar['postgresql']['sslcert']}}
        - user: postgres
        - group: root
        - mode: 400
        - contents_pillar: ssl:postgresql:combined
        - require:
            - file: ssl-cert-location


postgresql-ssl-key:
    file.managed:
        - name: {{pillar['postgresql']['sslkey']}}
        - user: postgres
        - group: root
        - mode: 400
        - contents_pillar: ssl:postgresql:key
        - require:
            - file: ssl-key-location
{% endif %}

{% if "sslcert" in pillar["postgresql"] %}
data-cluster-config-sslcert:
    file.replace:
        - name: /etc/postgresql/{{postgres_version}}/main/postgresql.conf
        - pattern: ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'[^\n]*$
        - repl: ssl_cert_file = '{{pillar['postgresql']['sslcert']
            if pillar['postgresql'].get('sslcert', 'default') != 'default'
            else pillar['ssl']['filenames']['default-cert-combined']}}'
        - backup: False
        - require_in:
            - file: postgresql-hba-config


data-cluster-config-sslkey:
    file.replace:
        - name: /etc/postgresql/{{postgres_version}}/main/postgresql.conf
        - pattern: ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'[^\n]*$
        - repl: ssl_key_file = '{{pillar['postgresql']['sslkey']
            if pillar['postgresql'].get('sslcert', 'default') != 'default'
            else pillar['ssl']['filenames']['default-cert-key']}}'
        - backup: False
        - require_in:
            - file: postgresql-hba-config

data-cluster-config-sslciphers:
    file.replace:
        - name: /etc/postgresql/{{postgres_version}}/main/postgresql.conf
        - pattern: "^#ssl_ciphers\\s+=\\s+'HIGH:MEDIUM:\\+3DES:!aNULL'[^\n]*$"
        - repl: >
            ssl_ciphers = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:
            ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:
            DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:
            ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:
            ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:
            DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:
            AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
        - backup: False
        - require_in:
            - file: postgresql-hba-config
{% endif %}

{% if pillar.get("ssl", {}).get("environment-rootca-cert", None) %}
# trust the installed per-environment CA to authenticate users for this database
# that were collected in the postgresql-hba-certusers-accumulator accumulator
data-cluster-config-ssl_client_ca:
    file.replace:
        - name: /etc/postgresql/{{postgres_version}}/main/postgresql.conf
        - pattern: "^#ssl_ca_file = ''[^\n]*$"
        - repl: ssl_ca_file = '{{pillar['ssl']['environment-rootca-cert']}}'
        - backup: False
        - require_in:
            # when pg_hba has sslcert users ssl_ca_cert must be set in postgresql.conf first
            - file: postgresql-hba-config
    {% if pillar.get('postgresql', {}).get('start-cluster', True) %}
        - watch_in:
            - service: data-cluster-service
    {% endif %}
        - require:
            - require-ssl-certificates
{% endif %}

{% if pillar.get('postgresql', {}).get('start-cluster', True) %}
data-cluster-service:
    service.running:
        - name: postgresql@{{postgres_version}}-main
        - sig: /usr/lib/postgresql/{{postgres_version}}/bin/postgres
        - enable: True
        - order: 15  # see ORDER.md
        - watch:
            - file: postgresql-hba-config
            - file: data-cluster-config-base
{% if pillar.get("ssl", {}).get("postgresql") %}
            - file: postgresql-ssl-cert
            - file: postgresql-ssl-key
            - file: data-cluster-config-sslcert
            - file: data-cluster-config-sslkey
            - file: data-cluster-config-sslciphers
{% endif %}
        - require_in:
            - cmd: postgresql-sync
{% endif %}

postgresql-servicedef:
    file.managed:
        - name: /etc/consul/services.d/postgresql.json
        - source: salt://postgresql/consul/postgresql.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{ip}}
            port: {{port}}
        - require:
            - file: consul-service-dir
        - require_in:
            - cmd: postgresql-sync
{% if pillar.get('postgresql', {}).get('start-cluster', True) %}
            - service: data-cluster-service
{% endif %}


postgresql-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: tcp
        - source: '0/0'
        - in-interface: {{pillar['ifassign']['internal']}}
        - destination: {{ip}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
# We're dumping the whole cluster, so we just pretend that /secure will always exist if
# duplicity backup is enabled. This is so because otherwise we might dump sensitive data on
# and unencrypted partition. This could be handled better if secure databases were handled
# by a separate postgresql cluster.
postgresql-backup-target:
    file.directory:
        - name: /secure/postgres-backup
        - user: postgres
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount


postgresql-backup-prescript-folder:
    file.directory:
        - name: /etc/duplicity.d/daily/prescripts/postgres-backup
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


postgresql-backup-postscript-folder:
    file.directory:
        - name: /etc/duplicity.d/daily/postscripts/postgres-backup
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


postgresql-backup-prescript:
    file.managed:
        - name: /etc/duplicity.d/daily/prescripts/postgres-backup/clusterbackup.sh
        - contents: |
            #!/bin/bash
            # The below command will fail if there are more table spaces than those configured in this Salt config.
            su -s /bin/bash -c "/usr/bin/pg_basebackup -D /secure/postgres-backup/backup \
                --waldir /secure/postgres-backup/wal \
                -X stream -R -T /secure/postgres/main=/secure/postgres-backup/backup-secure" postgres
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: postgresql-backup-prescript-folder


postgresql-backup-postscript:
    file.managed:
        - name: /etc/duplicity.d/daily/postscripts/postgres-backup/removebackup.sh
        - contents: |
            #!/bin/bash
            # remove backup files after duplicity has processed them, because pg_basebackup will not
            # proceed if its target directory isn't empty.
            rm -rf /secure/postgres-backup/*
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: postgresql-backup-postscript-folder


postgresql-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/postgres-backup
        - target: /secure/postgres-backup
        - require:
            - file: postgresql-backup-target
{% endif %}

# vim: syntax=yaml
