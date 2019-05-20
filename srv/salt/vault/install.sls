
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
        - user: root
        - group: root
        - mode: '0755'
        - replace: False
        - require:
            - user: vault
            - archive: vault


# the vault executable must have the "cap_ipc_lock=+ep" flag so it can lock memory from swap.
# Regardless, ideally Vault runs on a server with encrypted swap space. However even if it doesn't then locking the
# memory will provide additional security. For more information see `man setcap` and `man cap_from_text`, the latter
# is part of "libcap-dev" on Debian.
vault-setcap:
    cmd.run:
        - name: setcap cap_ipc_lock=+ep /usr/local/bin/vault
        - cwd: /usr/local/bin
        - runas: root
        - unless: getcap /usr/local/bin/vault | grep cap_ipc_lock >/dev/null
        - require:
            - file: vault
        - require_in:
            - cmd: vault-sync


vault-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/50-vault.rsyslog.conf
        - source: salt://vault/50-vault.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'
