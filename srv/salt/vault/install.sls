
{% set vault_user = "vault" %}
{% set vault_group = "vault" %}

vault:
    group.present:
        - name: {{vault_group}}
    user.present:
        - name: {{vault_user}}
        - gid: {{vault_group}}
        - groups:
            - ssl-cert
        - createhome: False
        - home: /etc/vault
        - shell: /bin/sh
        - require:
            - group: vault
            - group: ssl-cert
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["vault"]}}
        - source_hash: {{pillar["hashes"]["vault"]}}
        - archive_format: zip
        - unless: test -f /usr/local/bin/vault  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/bin/vault
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/vault
        - user: {{vault_user}}
        - group: {{vault_user}}
        - mode: '0755'
        - replace: False
        - require:
            - user: vault
            - file: vault-data-dir
            - archive: vault
