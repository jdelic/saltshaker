include:
    - vaultwarden.sync
    - vault.sync
    - vault.install


{% set ip = pillar.get('vaultwarden', {}).get(
        'bind-ip',
        grains['ip_interfaces'][pillar['ifassign']['internal']][
            pillar['ifassign'].get('internal-ip-index', 0)|int
        ]
    )
%}

{% set port = pillar.get('vaultwarden', {}).get('bind-port', 31080) %}


vaultwarden-data:
    file.directory:
        - name: /secure/vaultwarden
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount


vaultwarden-envdir:
    file.directory:
        - name: /etc/appconfig/vaultwarden/env
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True


vaultwarden-envfile-base:
    file.managed:
        - name: /etc/appconfig/vaultwarden/env/env-file
        - user: root
        - group: root
        - mode: '0640'
        - contents: |
            # Managed by Salt
            SSO_ENABLED=True
            SSO_AUTHORITY=https://{{pillar['authserver']['hostname']}}/o2/
            SMTP_HOST={{pillar['smtp']['smartstack-hostname']}}
            SMTP_PORT=25
            SMTP_FROM=vaultwarden@{{pillar['vaultwarden']['hostname']}}
            DATABASE_URL=postgres://vaultwarden:{{pillar['dynamicsecrets']['vaultwarden-db']}}@{{pillar['postgresql']['smartstack-hostname']}}/vaultwarden?sslmode=require&sslrootcert={{pillar['ssl']['service-rootca-cert']}}
            EXTENDED_LOGGING=true
            LOG_LEVEL=debug
            # Filled later if Vault available
            SSO_CLIENT_ID=UNKNOWN_RERUN_SALT
            SSO_CLIENT_SECRET=UNKNOWN_RERUN_SALT
        - require:
            - file: vaultwarden-envdir


vaultwarden-envfile-secrets:
    cmd.run:
        - name: |
            set -eu

            ENV_FILE="/etc/appconfig/vaultwarden/env/env-file"

            CID="$(/usr/local/bin/vault kv get -field=client_id secret/oauth2/vaultwarden)"
            CSEC="$(/usr/local/bin/vault kv get -field=client_secret secret/oauth2/vaultwarden)"

            if grep -q '^SSO_CLIENT_ID=' "$ENV_FILE"; then
                sed -i "s/^SSO_CLIENT_ID=.*/SSO_CLIENT_ID=${CID}/" "$ENV_FILE"
            else
                echo "SSO_CLIENT_ID=${CID}" >> "$ENV_FILE"
            fi

            if grep -q '^SSO_CLIENT_SECRET=' "$ENV_FILE"; then
                sed -i "s/^SSO_CLIENT_SECRET=.*/SSO_CLIENT_SECRET=${CSEC}/" "$ENV_FILE"
            else
                echo "SSO_CLIENT_SECRET=${CSEC}" >> "$ENV_FILE"
            fi
        - env:
            VAULT_ADDR: https://vault.service.consul:8200/
            VAULT_TOKEN: {{pillar.get('dynamicsecrets', {}).get('vaultwarden-oidc-reader-token', '')}}
        - require:
            - file: vaultwarden-envfile-base
            - sls: vault.install
            - cmd: vault-sync
        - onlyif:
            - test -x /usr/local/bin/vault
            - test -n "{{pillar.get('dynamicsecrets', {}).get('vaultwarden-oidc-reader-token', '')}}"


vaultwarden-container:
    cmd.run:
        - name: |
            set -eu

            docker pull vaultwarden/server:latest >/dev/null

            if docker ps --format '{{"{{"}}.Names{{"}}"}}' | grep -qx 'vaultwarden'; then
                docker stop -t 30 vaultwarden
            fi

            if docker ps -a --format '{{"{{"}}.Names{{"}}"}}' | grep -qx 'vaultwarden'; then
                docker rm vaultwarden
            fi

            docker run -d \
                --name vaultwarden \
                --restart unless-stopped \
                --env-file /etc/appconfig/vaultwarden/env/env-file \
                -v /secure/vaultwarden:/data \
                -v {{pillar['ssl']['service-rootca-cert']}}:{{pillar['ssl']['service-rootca-cert']}}:ro \
                -p {{ip}}:{{port}}:80/tcp \
                --add-host {{pillar['postgresql']['smartstack-hostname']}}:{{pillar['docker']['bridge-ip']}} \
                --add-host {{pillar['authserver']['hostname']}}:192.168.123.163 \
                vaultwarden/server:latest >/dev/null
        - require:
            - file: vaultwarden-data
            - file: vaultwarden-envfile-base
            - cmd: vaultwarden-sync-postgres
            - cmd: vaultwarden-sync-oidc
            - cmd: vaultwarden-sync-vault
        - watch:
            - file: vaultwarden-envfile-base
            - cmd: vaultwarden-envfile-secrets


vaultwarden-http-tcp-in{{port}}-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


vaultwarden-http-tcp-in{{port}}-forward-ipv4:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - dport: {{port}}
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


vaultwarden-postgres-tcp-out5432-forward-ipv4:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - dport: 5432
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


#vaultwarden-postgres-tcp-in5432-ipv4:
#    nftables.append:
#        - table: filter
#        - chain: input
#        - family: ip4
#        - jump: accept
#        - source: '0/0'
#        - destination: {{ip}}/32
#        - sport: 5432
#        - proto: tcp
#        - save: True
#        - require:
#            - sls: basics.nftables.setup


vaultwarden-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/vaultwarden-external.json
        - source: salt://vaultwarden/consul/vaultwarden.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: vaultwarden
            routing: external
            protocol: https
            suffix: ext
            mode: http
            ip: {{ip}}
            port: {{port}}
            hostname: {{pillar['vaultwarden']['hostname']}}
        - require:
            - file: consul-service-dir
