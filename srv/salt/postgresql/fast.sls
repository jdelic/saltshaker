
# setting create_main_cluster = false in postgresql-common will prevent the automativ
# creation of a postgres cluster when we install the database

postgresql-repo:
    pkgrepo.managed:
        - humanname: PostgreSQL official repos
        - name: {{pillar["repos"]["postgresql"]}}
        - file: /etc/apt/sources.list.d/postgresql.list
        - key_url: salt://postgresql/postgresql_44A07FCC7D46ACCC4CF8.pgp.key


postgresql-step1:
    pkg.installed:
        - name: postgresql-common
        - fromrepo: jessie-pgdg
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
            - postgresql-9.6
            - postgresql-client-9.6
            - libpq5
        - install_recommends: False
        - fromrepo: jessie-pgdg
        - require:
            - postgresql-step1


data-cluster:
    cmd.run:
        - name: >
            /usr/bin/pg_createcluster -d /data/postgres/9.6/main --locale=en_US.utf-8 -e utf-8 -p 5432
            9.6 main
        - runas: root
        - unless: test -e /data/postgres/9.6/main
        - require:
            - postgresql-step2
            - data-base-dir


data-cluster-config-hba:
    file.append:
        - name: /etc/postgresql/9.6/main/pg_hba.conf
        - text: host all all {{pillar.get('postgresql', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}/24 md5
        - require:
            - cmd: data-cluster


data-cluster-config-network:
    file.append:
        - name: /etc/postgresql/9.6/main/postgresql.conf
        - text: listen_addresses = '{{pillar.get('postgresql', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}'
        - require:
            - cmd: data-cluster


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


data-cluster-config-sslcert:
    file.replace:
        - name: /etc/postgresql/9.6/main/postgresql.conf
        - pattern: ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'[^\n]*$
        - repl: ssl_cert_file = '{{pillar['postgresql']['sslcert']}}'
        - backup: False


data-cluster-config-sslkey:
    file.replace:
        - name: /etc/postgresql/9.6/main/postgresql.conf
        - pattern: ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'[^\n]*$
        - repl: ssl_key_file = '{{pillar['postgresql']['sslkey']}}'
        - backup: False


data-cluster-config-sslciphers:
    file.replace:
        - name: /etc/postgresql/9.6/main/postgresql.conf
        - pattern: "^#ssl_ciphers\\s+=\\s+'HIGH:MEDIUM:\\+3DES:!aNULL'[^\n]*$"
        - repl: ssl_ciphers = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
        - backup: False
{% endif %}

data-cluster-service:
    service.running:
        - name: postgresql@9.6-main
        - sig: /usr/lib/postgresql/9.6/bin/postgres
        - enable: True
        - order: 15  # see ORDER.md
        - watch:
            - file: data-cluster-config-hba
            - file: data-cluster-config-network
{% if pillar.get("ssl", {}).get("postgresql") %}
            - file: postgresql-ssl-cert
            - file: postgresql-ssl-key
            - file: data-cluster-config-sslcert
            - file: data-cluster-config-sslkey
            - file: data-cluster-config-sslciphers
{% endif %}


postgresql-in{{pillar.get('postgresql', {}).get('bind-port', 5432)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: tcp
        - source: '0/0'
        - in-interface: {{pillar['ifassign']['internal']}}
        - destination: {{pillar.get('postgresql', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('postgresql', {}).get('bind-port', 5432)}}
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables


postgresql-servicedef:
    file.managed:
        - name: /etc/consul/services.d/postgresql.json
        - source: salt://postgresql/consul/postgresql.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('postgresql', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('postgresql', {}).get('bind-port', 5432)}}
        - require:
            - cmd: data-cluster
            - file: consul-service-dir


# vim: syntax=yaml
