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
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["goldfish"]}}
        - source_hash: {{pillar["hashes"]["goldfish"]}}
        - archive_format: zip
        - unless: test -f /usr/local/bin/goldfish-linux-amd64  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/bin/goldfish-linux-amd64
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/goldfish-linux-amd64
        - user: {{goldfish_user}}
        - group: {{goldfish_user}}
        - mode: '0755'
        - replace: False
        - require:
            - user: goldfish
            - archive: goldfish


goldfish-approle-secret-id:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write -f -wrap-ttl=15m \
                auth/approle/role/{{pillar['dynamicsecrets']['goldfish-role-id']}}/secret-id
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            file: vault


goldfish-service:
    file.managed:
        - name: /etc/systemd/system/goldfish.service
        - source: salt://vault/goldfish.jinja.service
        - template: jinja
        - context:
            user: {{goldfish_user}}
            group: {{goldfish_group}}
    service.running:
        - watch:
            file: goldfish
            file: goldfish-service
            file: goldfish-config


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
