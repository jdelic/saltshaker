
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
            - postgresql-9.5
            - postgresql-client-9.5
            - libpq5
        - fromrepo: jessie-pgdg
        - require:
            - postgresql-step1


data-cluster:
    cmd.run:
        - name: >
            /usr/bin/pg_createcluster -d /data/postgres/9.5/main --locale=en_US.utf-8 -e utf-8 -p 5432
            9.5 main
        - runas: root
        - unless: test -e /data/postgres/9.5/main
        - require:
            - postgresql-step2
            - data-base-dir


data-cluster-config-hba:
    file.append:
        - name: /etc/postgresql/9.5/main/pg_hba.conf
        - text: host all all {{pillar.get('postgresql-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}/24 md5
        - require:
            - cmd: data-cluster


data-cluster-config-network:
    file.append:
        - name: /etc/postgresql/9.5/main/postgresql.conf
        - text: listen_addresses = '{{pillar.get('postgresql-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}'
        - require:
            - cmd: data-cluster


data-cluster-service:
    service.running:
        - name: postgresql@9.5-main
        - sig: postgres
        - enable: True
        - require:
            - file: data-cluster-config-hba
            - file: data-cluster-config-network


postgresql-in{{pillar.get('postgresql-server', {}).get('bind-port', 5432)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: tcp
        - source: '0/0'
        - in-interface: {{pillar['ifassign']['internal']}}
        - destination: {{pillar.get('postgresql-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('postgresql-server', {}).get('bind-port', 5432)}}
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
            ip: {{pillar.get('postgresql-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('postgresql-server', {}).get('bind-port', 5432)}}
        - require:
            - cmd: data-cluster
            - file: consul-service-dir


# vim: syntax=yaml
