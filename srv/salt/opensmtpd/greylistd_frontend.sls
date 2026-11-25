include:
    - opensmtpd.install
    - opensmtpd.sync
    - vault.install
    - vault.sync


{% set config = pillar['greylistd-frontend'] %}
{% set ip = config.get(
        'bind-ip',
        grains['ip_interfaces'][pillar['ifassign']['internal']][
            pillar['ifassign'].get('internal-ip-index', 0)|int
        ]
    )
%}
{% set port = config.get('bind-port', 31090) %}
{% set envdir = '/etc/appconfig/greylistd-frontend/env' %}
{% set oidc_reader_token = pillar.get('dynamicsecrets', {}).get('greylistd-frontend-oidc-reader-token', '') %}


greylistd-frontend:
    pkg.installed:
        - name: greylistd-frontend
        - fromrepo: mn-release
        - install_recommends: False
        - require:
            - pkg: greylistd
    systemdunit.managed:
        - name: /etc/systemd/system/greylistd-frontend.service
        - source: salt://opensmtpd/greylistd-frontend.jinja.service
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
        - context:
            envdir: {{envdir}}
    service.running:
        - name: greylistd-frontend
        - enable: True
        - require:
            - service: greylistd
            - cmd: greylistd-frontend-oidc-credentials
        - watch:
            - pkg: greylistd-frontend
            - systemdunit: greylistd-frontend
            - file: greylistd-frontend-envfile
            - cmd: greylistd-frontend-oidc-credentials


greylistd-frontend-envdir:
    file.directory:
        - name: {{envdir}}
        - user: root
        - group: root
        - mode: '0700'
        - makedirs: True


greylistd-frontend-envfile:
    file.managed:
        - name: {{envdir}}/envvars
        - user: root
        - group: root
        - mode: '0600'
        - contents: |
            # Managed by Salt
            GREYLISTD_FRONTEND_LISTEN={{ip}}:{{port}}
            GREYLISTD_FRONTEND_TRUST_PROXY=true
            GREYLISTD_FRONTEND_SOCKET=/run/greylistd/socket
            GREYLISTD_FRONTEND_BASE_URL=https://{{config['hostname']}}
            GREYLISTD_FRONTEND_TIMEZONE=UTC
            GREYLISTD_FRONTEND_SESSION_SECRET={{pillar['dynamicsecrets']['greylistd-frontend-session-secret']}}
            GREYLISTD_FRONTEND_OIDC_ISSUER=https://{{pillar['authserver']['hostname']}}/o2
            # authserver enforces greylistd-frontend:require-permission
            GREYLISTD_FRONTEND_OIDC_ALLOW_ANY_USER=true
        - require:
            - file: greylistd-frontend-envdir


greylistd-frontend-oidc-credentials:
    cmd.run:
        - name: |
            set -eu
            umask 077
            CID="$(/usr/local/bin/vault kv get -field=client_id secret/oauth2/greylistd-frontend)"
            CSEC="$(/usr/local/bin/vault kv get -field=client_secret secret/oauth2/greylistd-frontend)"
            printf 'GREYLISTD_FRONTEND_OIDC_CLIENT_ID=%s\nGREYLISTD_FRONTEND_OIDC_CLIENT_SECRET=%s\n' \
                "$CID" "$CSEC" > {{envdir}}/oidc.new
            if cmp -s {{envdir}}/oidc.new {{envdir}}/oidc; then
                rm -f {{envdir}}/oidc.new
                echo "changed=no comment='OIDC client credentials unchanged'"
            else
                mv {{envdir}}/oidc.new {{envdir}}/oidc
                echo "changed=yes comment='OIDC client credentials updated from Vault'"
            fi
        - stateful: True
        - env:
            VAULT_ADDR: https://vault.service.consul:8200/
            VAULT_TOKEN: {{oidc_reader_token}}
        - onlyif:
            - test -x /usr/local/bin/vault
            - test -n "{{oidc_reader_token}}"
        - require:
            - file: greylistd-frontend-envdir
            - sls: vault.install
            - cmd: vault-sync
            - cmd: greylistd-frontend-sync-oidc
            - cmd: greylistd-frontend-sync-vault


greylistd-frontend-http-tcp-in{{port}}-ipv4:
    nftables.append:
        - table: saltshaker
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - require:
            - sls: basics.nftables.setup


greylistd-frontend-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/greylistd-frontend-external.json
        - source: salt://opensmtpd/consul/greylistd-frontend.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: external
            protocol: https
            suffix: ext
            mode: http
            ip: {{ip}}
            port: {{port}}
            hostname: {{config['hostname']}}
        - require:
            - file: consul-service-dir
