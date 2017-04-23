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
        - require:
            - user: vault
            - group: vault


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


# the vault executable must have the "cap_ipc_lock=+ep" flag so it can lock memory from swap.
# Regardless, ideally Vault runs on a server with encryptd swap space. However even if it doesn't then locking the
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


vault-config:
    file.managed:
        - name: /etc/vault/vault.conf
        - source: salt://vault/vault.jinja.conf
        - template: jinja
        - user: {{vault_user}}
        - group: {{vault_group}}
        - mode: '0640'
        - context:
            ip: {{pillar.get('vault', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0
                    )|int()]
                )}}
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
            - file: vault-config
            - file: vault-ssl-cert
            - file: vault-ssl-key
    service.running:
        - name: vault
        - sig: vault
        - enable: True
        - require:
            - file: vault-service
            {% if 'consulserver' in grains['roles'] and pillar['vault']['backend'] == 'consul' %}
            - service: consul-server-service
            {% elif 'consulserver' not in grains['roles'] and pillar['vault']['backend'] == 'consul' %}
            - service: consul-agent-service
            {% endif %}
            {% if 'database' in grains['roles'] and pillar['vault']['backend'] == 'postgresql' %}
                {# when we're on the same machine as the PostgreSQL database, wait for it to come up and the #}
                {# database to be configured #}
            - service: data-cluster-service
            - vault-postgres
            {% endif %}
        - watch:
            - file: vault-service
            - file: vault  # restart on a change of the binary
            - file: vault-ssl-cert  # restart when the SSL cert changes
            - file: vault-ssl-key
            - service: smartstack-internal


{% if pillar['vault'].get('initialize', False) %}
vault-init:
    cmd.run:
        {% if pillar['vault'].get('encrypt-vault-keys-with-gpg', False) %}
            {% set long_id = pillar['vault']['encrypt-vault-keys-with-gpg'][-16:] %}
            {% set keyloc = pillar['gpg']['shared-keyring-location'] %}
        # use Bash process groups and fd pipes to send vault init's output into three separate
        # pipes:
        #   1. encrypt the output for the administrator
        #   2. save the initial root token to a file in /root and authenticate root as Vault root
        #   3. unseal Vault
        - name: >-
            {
                {
                    {
                        /usr/local/bin/vault init |
                        tee /dev/fd/5 /dev/fd/6 |
                        gpg --homedir {{keyloc}} \
                            --no-default-keyring \
                            --keyring {{salt['file.join'](keyloc, "pubring.gpg")}} \
                            --secret-keyring {{salt['file.join'](keyloc, "secring.gpg")}} \
                            --trustdb {{salt['file.join'](keyloc, "trustdb.gpg")}} \
                            --batch \
                            --trusted-key {{long_id}} -a -e \
                            -r {{pillar['vault']['encrypt-vault-keys-with-gpg']}} >/root/vault_keys.txt.gpg;
                    } 5>&1 |
                    grep "Initial Root Token" |
                    cut -f2 -d":" |
                    tr -d "[:space:]" >/root/.vault_token;
                } 6>&1 |
                grep "Unseal Key" |
                cut -f2 -d":" |
                tail -n 3 |
                xargs -n 1 vault unseal;
                cat /root/.vault_token | /usr/local/bin/vault auth -;
            }
        {% else %}
        - name: >-
            {
                {
                    {
                        /usr/local/bin/vault init |
                        tee /dev/fd/5 /dev/fd/6 >/root/vault_keys.txt;
                    } 5>&1 |
                    grep "Initial Root Token" |
                    cut -f2 -d":" |
                    tr -d "[:space:]" >/root/.vault_token;
                } 6>&1 |
                grep "Unseal Key" |
                cut -f2 -d':' |
                tail -n 3 |
                xargs -n 1 vault unseal;
                cat /root/.vault_token | /usr/local/bin/vault auth -;
            }
        {% endif %}
        - unless: /usr/local/bin/vault init -check >/dev/null
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"
        - require:
            - file: managed-keyring
            - service: vault-service


# Vault clients configured by Salt should watch for this state using cmd.run:onchanges'
# and set up their CA certificate and policies
vault-cert-auth-enabled:
    cmd.run:
        - name: /usr/local/bin/vault auth-enable cert
        - unless: /usr/local/bin/vault auth -methods | grep cert >/dev/null
        - env:
            - VAULT_ADDR: "https://{{pillar['vault']['smartstack-hostname']}}:8200/"
        - require:
            - service: vault-service
            - cmd: vault-init
{% endif %}


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


vault-servicedef:
    file.managed:
        - name: /etc/consul/services.d/vault.json
        - source: salt://vault/consul/vault.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('vault', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0
                    )|int()]
                )}}
            port: {{pillar.get('vault', {}).get('bind-port', 8200)}}
        - require:
            - file: consul-service-dir
            - file: vault-service


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
