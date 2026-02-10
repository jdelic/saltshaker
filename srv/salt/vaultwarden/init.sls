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
        - name: /etc/appconfig/vaultwarden/env/envvars
        - user: root
        - group: root
        - mode: '0640'
        - contents: |
            # Managed by Salt
            DOMAIN=https://{{pillar['vaultwarden']['hostname']}}
            SSO_ENABLED=True
            SSO_AUTHORITY=https://{{pillar['authserver']['hostname']}}/o2
            SMTP_HOST={{pillar['smartstack-services']['smtp']['smartstack-hostname']}}
            SMTP_PORT=25
            SMTP_FROM=vaultwarden@{{pillar['vaultwarden']['hostname']}}
            DATABASE_URL=postgres://vaultwarden:{{pillar['dynamicsecrets']['vaultwarden-db']}}@{{pillar['smartstack-services']['postgresql']['smartstack-hostname']}}/vaultwarden?sslmode=require&sslrootcert={{pillar['ssl']['service-rootca-cert']}}
            EXTENDED_LOGGING=true
            LOG_LEVEL=warn
            SIGNUPS_ALLOWED=false
            # Filled later when Vault is available
            SSO_CLIENT_ID=UNKNOWN_RERUN_SALT
            SSO_CLIENT_SECRET=UNKNOWN_RERUN_SALT
        - require:
            - file: vaultwarden-envdir


vaultwarden-add-encrypted-admin-token:
    {% set long_id = pillar['vaultwarden']['encrypt-admin-token-with-gpg-key'] %}
    {% set keyloc = pillar[ 'gpg' ][ 'shared-keyring-location' ] %}
    pkg.installed:
        - name: argon2
    {% if long_id %}
    cmd.run:
        # we use bash process groups to gpg encrypt the token for the admin without ever writing it to disk and
        # hash it at the same time to write it to the config envvars.
        - name: |
             {
                 head -c 20 /dev/urandom | base64 -w 0 | tee /dev/fd/5 |
                 gpg --homedir {{keyloc}} \
                     --no-default-keyring \
                     --batch \
                     --trusted-key {{long_id}} -a -e \
                     -r {{long_id}} >/root/vaultwarden_admin_token.txt.gpg;
                 echo -n "ADMIN_TOKEN=" >> /etc/appconfig/vaultwarden/env/envvars;
             } 5> >(argon2 $(head -c 16 /dev/urandom | base64) -e >> /etc/appconfig/vaultwarden/env/envvars)
        - require:
            - pkg: vaultwarden-add-encrypted-admin-token
            - file: vaultwarden-envfile-base
            - file: managed-keyring
        - unless:
            - test -f /root/vaultwarden_admin_token.txt.gpg
            - grep -q '^ADMIN_TOKEN=' /etc/appconfig/vaultwarden/env/envvars
    {% else %}
    cmd.run:
        - name: |
            echo -n "ADMIN_TOKEN=" >> /etc/appconfig/vaultwarden/env/envvars;
            head -c 20 /dev/urandom | base64 -w 0 | tee /root/vaultwarden_admin_token.txt |
            argon2 $(head -c 16 /dev/urandom | base64) -e >> /etc/appconfig/vaultwarden/env/envvars
        - require:
            - pkg: vaultwarden-add-encrypted-admin-token
            - file: vaultwarden-envfile-base
        - unless:
            - test -f/root/vaultwarden_admin_token.txt
            - grep -q '^ADMIN_TOKEN=' /etc/appconfig/vaultwarden/env/envvars
    {% endif %}


vaultwarden-envfile-secrets:
    cmd.run:
        - name: |
            set -eu

            ENV_FILE="/etc/appconfig/vaultwarden/env/envvars"

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
            - grep -q '^SSO_CLIENT_ID=UNKNOWN_RERUN_SALT' /etc/appconfig/vaultwarden/env/envvars


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
                --env-file /etc/appconfig/vaultwarden/env/envvars \
                -v /secure/vaultwarden:/data \
                -v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro \
                -p {{ip}}:{{port}}:80/tcp \
                {%- for s in pillar['smartstack-services'] %}
                --add-host={{pillar['smartstack-services'][s]['smartstack-hostname']}}:{{pillar['docker']['bridge-ip']}} \
                {%- endfor %}
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
            - cmd: vaultwarden-add-encrypted-admin-token


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
