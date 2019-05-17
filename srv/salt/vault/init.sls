#
# Installs Hashicorp Vault in /usr/local/bin from a binary distribution downloaded from the internet.
# The service is published via consul and also stores data in the local consul cluster discovered via the
# saltmine (see consul.install for details on the local consul cluster which must exist if you're using this
# saltshaker). Applications can then use Vault nodes to get credentials like SSL certificates, AWS access
# credentials and more.
#

include:
    - vault.install
    - vault.sync
    - powerdns.sync
    - postgresql.sync


{% from 'vault/install.sls' import vault_user, vault_group %}


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


vault-plugin-dir:
    file.directory:
        - name: /usr/local/lib/vault/
        - makedirs: True
        - user: root
        - group: vault
        - mode: '0750'
        - require:
            - group: vault


vault-plugin-gpg:
    archive.extracted:
        - name: /usr/local/lib/vault
        - source: {{pillar["urls"]["vault-gpg-plugin"]}}
        - source_hash: {{pillar["hashes"]["vault-gpg-plugin"]}}
        - archive_format: zip
        - unless: test -f /usr/local/lib/vault/vault-gpg-plugin  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/lib/vault-vault-gpg-plugin
        - enforce_toplevel: False
        - require:
            - file: vault-plugin-dir
    file.managed:
        - name: /usr/local/lib/vault/vault-gpg-plugin
        - user: root
        - group: root
        - mode: '0755'
        - replace: False
        - require:
            - archive: vault-plugin-gpg


vault-plugin-gpg-setcap:
    cmd.run:
        - name: setcap cap_ipc_lock=+ep /usr/local/lib/vault/vault-gpg-plugin
        - cwd: /usr/local/lib/vault
        - runas: root
        - unless: getcap /usr/local/lib/vault/vault-gpg-plugin | grep cap_ipc_lock >/dev/null
        - require:
            - file: vault-plugin-gpg


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
    systemdunit.managed:
        - name: /etc/systemd/system/vault.service
        - source: salt://vault/vault.jinja.service
        - template: jinja
        - context:
            user: {{vault_user}}
            group: {{vault_group}}
        - require:
            - file: vault
            - cmd: vault-setcap
            - file: vault-config
            - file: vault-ssl-cert
            - file: vault-ssl-key
    service.running:
        - name: vault
        - sig: vault
        - enable: True
        - require:
            - cmd: consul-sync
            - cmd: powerdns-sync
            - file: vault-data-dir
            - file: vault-internal-servicedef
            {% if pillar['vault']['backend'] == 'postgresql' %}
                {# when we're on the same machine as the PostgreSQL database, wait for it to come up and the #}
                {# database to be configured #}
            - cmd: postgresql-sync
            - cmd: vault-sync-database
            {% endif %}
        - watch:
            - systemdunit: vault-service
            - file: vault  # restart on a change of the binary
            - file: vault-ssl-cert  # restart when the SSL cert changes
            - file: vault-ssl-key
            - service: smartstack-internal
    cmd.run:
        # any response code is fine, we just need the server to be there to continue with initialization etc.
        - name: >
            until test ${count} -gt 30; do
                RESP="$(curl -s -o /dev/null -w "%{http_code}" https://vault.service.consul:8200/v1/sys/health)"
                if test "$RESP" -ge 200; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
        - onchanges:
            - service: vault-service
        - require_in:
            - cmd: vault-sync


{% if pillar['vault'].get('initialize', False) %}
vault-init:
    cmd.run:
        {% if pillar['vault'].get('encrypt-vault-keys-with-gpg', False) %}
            {% set long_id = pillar['vault']['encrypt-vault-keys-with-gpg'][-16:] %}
            {% set keyloc = pillar['gpg']['shared-keyring-location'] %}
        # use Bash process groups and fd pipes to send vault operator init's output into three separate
        # pipes:
        #   1. encrypt the output for the administrator
        #   2. save the initial root token to a file in /root and authenticate root as Vault root
        #   3. unseal Vault
        - name: >-
            {
                {
                    {
                        /usr/local/bin/vault operator init |
                        tee /dev/fd/5 /dev/fd/6 |
                        gpg --homedir {{keyloc}} \
                            --no-default-keyring \
                            --batch \
                            --trusted-key {{long_id}} -a -e \
                            -r {{pillar['vault']['encrypt-vault-keys-with-gpg']}} >/root/vault_keys.txt.gpg;
                    } 5>&1 |
                    grep "Initial Root Token" |
                    cut -f2 -d":" |
                    tr -d "[:space:]" >/root/.vault-token;
                } 6>&1 |
                grep "Unseal Key" |
                cut -f2 -d":" |
                tail -n 3 |
                xargs -n 1 vault operator unseal;
                cat /root/.vault-token | /usr/local/bin/vault login -;
            }
        {% else %}
        - name: >-
            {
                {
                    {
                        /usr/local/bin/vault operator init |
                        tee /dev/fd/5 /dev/fd/6 >/root/vault_keys.txt;
                    } 5>&1 |
                    grep "Initial Root Token" |
                    cut -f2 -d":" |
                    tr -d "[:space:]" >/root/.vault-token;
                } 6>&1 |
                grep "Unseal Key" |
                cut -f2 -d':' |
                tail -n 3 |
                xargs -n 1 vault operator unseal;
                cat /root/.vault-token | /usr/local/bin/vault login -;
            }
        {% endif %}
        # vault check -init returns error code 1 on an ERROR and 2 when Vault is uninitialized
        # so we do nothing on exit codes 0 and 1
        - unless: /usr/local/bin/vault operator init -status >/dev/null || test $? -lt 2 && /bin/true
        # we use Vault's Consul DNS API name here, because we can't rely on SmartStack being available
        # when the node has just been brought up. It doesn't matter here though, because Vault is
        # by definition local to this node when this state runs.
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - file: managed-keyring
            - cmd: vault-service
            - cmd: powerdns-sync
        - require_in:
            - cmd: vault-sync


vault-secret-kv-enabled:
    cmd.run:
        - name: /usr/local/bin/vault secrets enable -path=secret/ kv
        - unless: /usr/local/bin/vault secrets list | grep '^secret/' >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - cmd: vault-service
            - cmd: vault-init
        - require_in:
            - cmd: vault-sync


# Vault clients configured by Salt should watch for this state using cmd.run:onchanges
# and set up their CA certificate and policies
vault-cert-auth-enabled:
    cmd.run:
        - name: /usr/local/bin/vault auth enable cert
        - unless: /usr/local/bin/vault auth list | grep cert >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        # we use Vault's Consul DNS API name here, because we can't rely on SmartStack being available
        # when the node has just been brought up. It doesn't matter here though, because Vault is
        # by definition local to this node when this state runs.
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - cmd: vault-service
            - cmd: vault-init
        - require_in:
            - cmd: vault-sync


# Vault clients configured by Salt should watch for this state using cmd.run:onchanges
# and set up their approles and policies
vault-approle-auth-enabled:
    cmd.run:
        - name: /usr/local/bin/vault auth enable approle
        - unless: /usr/local/bin/vault auth list | grep approle >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - cmd: vault-service
            - cmd: vault-init
        - require_in:
            - cmd: vault-sync


# create a token that can request secret-ids from approle
vault-approle-access-token-policy:
    cmd.run:
        - name: >-
            echo 'path "auth/approle/role/*" {
                capabilities = ["read", "create", "update", "list"]
            }' | /usr/local/bin/vault policy write approle_access -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep approle_access >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-init
        - require_in:
            - cmd: vault-sync


# this creates a token using a per-salt-cluster uuid from dynamicsecrets. The token
# will become invalid after 60 minutes unless the vault home runs this state again!
# This allows minions to create approle secret-ids for themselves but not create new
# secret ids after one hour. This is a compromise between automatic initialization and
# security.
vault-approle-access-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="approle-auth" \
                -policy=default -policy=approle_access \
                -renewable=true \
                -period=1h \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['approle-auth-token']}}"
        - unless: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['approle-auth-token']}} | jq -r .renewable)" == "true" ||
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['approle-auth-token']}} | jq -r .data.ttl)" -gt 100
        - require:
            - cmd: vault-init
            - cmd: vault-approle-access-token-policy
        - require_in:
            - cmd: vault-sync


vault-approle-access-token-renewal:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token renew $TOKENID
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['approle-auth-token']}}"
        - onlyif: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['approle-auth-token']}} | jq -r .renewable)" == "true"
        - require:
            - cmd: vault-init
            - cmd: vault-approle-access-token-policy
        - require_in:
            - cmd: vault-sync


vault-install-gpg-plugin:
    cmd.run:
        - name: >-
            /usr/local/bin/vault plugin register \
                -sha256="$(cat /usr/local/lib/vault/linux_amd64.sha256sum | cut -d' ' -f1)" \
                -command=vault-gpg-plugin gpg
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: >-
            /usr/local/bin/vault plugin list | grep "^gpg" >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-init
            - cmd: vault-plugin-gpg-setcap
        - require_in:
            - cmd: vault-sync


vault-init-gpg-plugin:
    cmd.run:
        - name: >-
            /usr/local/bin/vault secrets enable -path=gpg -plugin-name=gpg plugin
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: >-
            /usr/local/bin/vault secrets list | grep "gpg/" >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-init
            - cmd: vault-plugin-gpg-setcap
            - cmd: vault-install-gpg-plugin
        - require_in:
            - cmd: vault-sync


# create a token that can request GPG keys from Vault
vault-gpg-full-access-token-policy:
    cmd.run:
        - name: >-
            echo 'path "gpg/keys/*" {
                capabilities = ["read", "create", "update", "list"]
            }

            path "gpg/export/*" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write gpg_full_access -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep gpg_full_access >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-init-gpg-plugin
        - require_in:
            - cmd: vault-sync


# create a token that can request GPG keys from Vault
vault-gpg-read-access-token-policy:
    cmd.run:
        - name: >-
            echo 'path "gpg/keys/*" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write gpg_read_access -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep gpg_read_access >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-init-gpg-plugin
        - require_in:
            - cmd: vault-sync


# this creates a token using a per-salt-cluster uuid from dynamicsecrets. The token
# will become invalid after 60 minutes unless the vault home runs this state again!
# This allows minions to create GPG keys for themselves but not create new
# GPG keys after one hour. This is a compromise between automatic initialization and
# security.
vault-gpg-full-access-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="gpg-full" \
                -policy=default -policy=gpg_full_access \
                -renewable=true \
                -period=1h \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['gpg-auth-token']}}"
        - unless: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['gpg-auth-token']}} | jq -r .renewable)" == "true" ||
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['gpg-auth-token']}} | jq -r .data.ttl)" -gt 100
        - require:
            - cmd: vault-gpg-full-access-token-policy
        - require_in:
            - cmd: vault-sync


vault-gpg-full-access-token-renewal:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token renew $TOKENID
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['gpg-auth-token']}}"
        - onlyif: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['gpg-auth-token']}} | jq -r .renewable)" == "true"
        - require:
            - cmd: vault-init
            - cmd: vault-gpg-full-access-token-policy
        - require_in:
            - cmd: vault-sync


vault-gpg-read-access-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="gpg-read" \
                -policy=default -policy=gpg_read_access \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['gpg-read-token']}}"
        - unless: >-
            /usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['gpg-read-token']}}
        - require:
            - cmd: vault-gpg-read-access-token-policy
        - require_in:
            - cmd: vault-sync
{% endif %}


vault-service-reload:
    service.running:
        - name: vault
        - sig: vault
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload vault) instead of restarting
        - require:
            - systemdunit: vault-service
        - watch:
            - file: /etc/vault/vault.conf


vault-internal-servicedef:
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


{% if 'vault' in pillar and 'hostname' in pillar['vault'] %}
vault-external-servicedef:
    file.managed:
        - name: /etc/consul/services.d/vault-ui.json
        - source: salt://vault/consul/vault-ui.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('vault', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0
                    )|int()]
                )}}
            port: {{pillar.get('vault', {}).get('bind-port', 8200)}}
            hostname: {{pillar['vault']['hostname']}}
        - require:
            - file: consul-service-dir
{% endif %}


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
