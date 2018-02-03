# Only Vault Enterprise ships with a built-in UI. Thankfully, the open-source has come to the rescue with
# https://github.com/Caiyeon/goldfish, a standalone web UI for Vault built in Go.

{% set goldfish_user = "goldfish" %}
{% set goldfish_group = "goldfish" %}


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

