# Only Vault Enterprise ships with a built-in UI. Thankfully, the open-source has come to the rescue with
# https://github.com/Caiyeon/goldfish, a standalone web UI for Vault built in Go.

{% set goldfish_user = "goldfish" %}
{% set goldfish_group = "goldfish" %}
{% set ip = pillar.get('goldfish', {}).get('bind-ip',
                grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            ) %}
{% set port = 8201 %}

goldfish-config-dir:
    file.directory:
        - name: /etc/goldfish
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


goldfish-config:
    file.managed:
        - name: /etc/goldfish/goldfish.conf
        - source: salt://vault/goldfish.jinja.conf
        - template: jinja
        - context:
            ip: {{ip}}
            port: {{port}}
            dynamicsecrets_role_id: {{pillar['dynamicsecrets']['goldfish-role-id']}}
        - require:
            - file: goldfish-config-dir


goldfish:
    group.present:
        - name: {{goldfish_group}}
    user.present:
        - name: {{goldfish_user}}
        - gid: {{goldfish_group}}
        - groups:
            - ssl-cert
        - createhome: False
        - home: /etc/goldfish
        - shell: /bin/sh
        - require:
            - group: goldfish
            - group: ssl-cert
            - file: goldfish-config-dir
    file.managed:
        - name: /usr/local/bin/goldfish-linux-amd64
        - source: {{pillar["urls"]["goldfish"]}}
        - source_hash: {{pillar["hashes"]["goldfish"]}}
        - user: {{goldfish_user}}
        - group: {{goldfish_user}}
        - mode: '0755'
        - replace: False
        - require:
            - user: goldfish


goldfish-setcap:
    cmd.run:
        - name: setcap cap_ipc_lock=+ep /usr/local/bin/goldfish-linux-amd64
        - cwd: /usr/local/bin
        - runas: root
        - unless: getcap /usr/local/bin/goldfish-linux-amd64 | grep cap_ipc_lock >/dev/null
        - require:
            - file: goldfish


goldfish-service:
    file.managed:
        - name: /etc/systemd/system/goldfish.service
        - source: salt://vault/goldfish.jinja.service
        - template: jinja
        - context:
            user: {{goldfish_user}}
            group: {{goldfish_group}}
    service.running:
        - name: goldfish
        - watch:
            - file: goldfish
            - file: goldfish-service
            - file: goldfish-config


goldfish-servicedef:
    file.managed:
        - name: /etc/consul/services.d/goldfish.json
        - source: salt://vault/consul/vault_goldfish_ui.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: goldfish
            mode: http
            ip: {{ip}}
            port: {{port}}
            hostname: {{pillar['goldfish']['hostname']}}
        - require:
            - file: consul-service-dir


goldfish-tcp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
