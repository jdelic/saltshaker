#
# Installs Hashicorp Vault in /usr/local/bin from a binary distribution downloaded from the internet.
# The service is published via consul and also stores data in the local consul cluster discovered via the
# saltmine (see consul.install for details on the local consul cluster which must exist if you're using this
# saltshaker). Applications can then use Vault nodes to get credentials like SSL certificates, AWS access
# credentials and more.
#

{% set vault_user = "vault" %}
{% set vault_group = "vault" %}


vault-data-dir:
    file.directory:
        - name: /run/vault
        - makedirs: True
        - user: {{vault_user}}
        - group: {{vault_group}}
        - mode: '0755'
        - require:
            - user: vault
            - group: vault


vault-data-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/vault.conf
        - source: salt://vault/vault.tmpfiles.jinja.conf
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            user: {{vault_user}}
            group: {{vault_group}}
        - require:
            - user: vault  # the user is required in the .conf file
            - group: vault


vault-config-dir:
    file.directory:
        - name: /etc/vault
        - makedirs: True
        - user: {{vault_user}}
        - group: {{vault_group}}
        - mode: '0750'


vault:
    group.present:
        - name: {{vault_group}}
    user.present:
        - name: {{vault_user}}
        - gid: {{vault_group}}
        - createhome: False
        - home: /etc/vault
        - shell: /bin/sh
        - require:
            - group: vault
            - file: vault-config-dir
    archive.extracted:
        - name: /usr/local/bin
        - source: https://dl.bintray.com/mitchellh/vault/vault_0.2.0_linux_amd64.zip
        - source_hash: sha256=b4b64fcea765ebfc7cdbae9cdd2c32bff130ca51f15b9cf47194f112fd5515cf
        - archive_format: zip
        - if_missing: /usr/local/bin/vault
    file.managed:
        - name: /usr/local/bin/vault
        - user: {{vault_user}}
        - group: {{vault_user}}
        - mode: '0755'
        - require:
            - user: vault
            - file: vault-data-dir


# the vault executable must have the "cap_ipc_lock=+ep" flag so it can lock memory from swap.
# Regardless, ideally Vault runs on a server with encryptd swap space. However even if it doesn't then locking the
# memory will provide additional security. For more information see `man setcap` and `man cap_from_text`, the latter
# is part of "libcap-dev" on Debian.
vault-setcap:
    cmd.run:
        - name: setcap cap_ipc_lock=+ep /usr/local/bin/vault
        - cwd: /usr/local/bin
        - user: root
        - group: root
        - unless: getcap /usr/local/bin | grep -q cap_ipc_lock


/etc/vault/vault.conf:
    file.managed:
        - source: salt://vault/vault.jinja.conf
        - template: jinja
        - user: {{vault_user}}
        - group: {{vault_group}}
        - context:
            ip: {{pillar.get('vault', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('vault', {}).get('bind-port', 8200)}}
        - require:
            - file: vault-config-dir


vault-service:
    file.managed:
        - name: /etc/systemd/system/vault.service
        - source: salt://vault/vault.jinja.service
        - template: jinja
        - context:
            user: {{vault_user}}
            group: {{vault_group}}
        - require:
            - file: vault
            - file: /etc/vault/vault.conf
    service.running:
        - name: vault
        - sig: vault
        - enable: True
        - require:
            - file: vault-service
        - watch:
            - file: vault-service


vault-service-reload:
    service.running:
        - name: vault
        - sig: vault
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload vault) instead of restarting
        - require:
            - file: vault-service
        - watch:
            - file: /etc/vault/vault.conf


/etc/consul/services.d/vault.json:
    file.managed:
        - source: salt://vault/consul/vault.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('vault', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('vault', {}).get('bind-port', 8200)}}
        - require:
            - service: vault-service


vault-ssl-cert:
    file.managed:
        - name: {{pillar['vault']['sslcert']}}
        - user: vault
        - group: root
        - mode: 400
        - contents_pillar: ssl:vault:combined
        - require:
            - file: ssl-cert-location


vault-ssl-key:
    file.managed:
        - name: {{pillar['vault']['sslkey']}}
        - user: vault
        - group: root
        - mode: 400
        - contents_pillar: ssl:vault:key
        - require:
            - file: ssl-key-location


# This is for contacting Vault. Outgoing connections to port 8200 are covered by basics.sls
vault-tcp8200-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 8200
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
