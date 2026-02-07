include:
    - vaultwarden.sync

{% set ip = pillar.get('vaultwarden', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            ) %}

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


vaultwarden:
    docker_container.running:
        - name: vaultwarden
        - image: vaultwarden/server:latest
        - restart_policy: unless-stopped
        - binds:
            - /secure/vaultwarden:/data
        - publish:
            - "{{ip}}:{{port}}:80/tcp"
        - environment:
            - SSO_ENABLED: True
            - SSO_AUTHORITY: https://{{pillar['authserver']['hostname']}}/o2/
            - SMTP_HOST: {{pillar['smtp']['smartstack-hostname']}}
            - SMTP_PORT: 25
            - SMTP_FROM: vaultwarden@{{pillar['vaultwarden']['hostname']}}
            - DATABASE_URL: postgres://vaultwarden:{{pillar['dynamicsecrets']['vaultwarden-db']}}@{{pillar['postgresql']['smartstack-hostname']}}/vaultwarden
            - SSO_CLIENT_ID: {{salt['cmd.run_stdout']('/usr/local/bin/vault kv get -field=client_id secret/oauth2/vaultwarden',
                                                      env={'VAULT_ADDR': 'https://vault.service.consul:8200/',
                                                           'VAULT_TOKEN': pillar['dynamicsecrets']['vaultwarden-oidc-reader-token']})}}
            - SSO_CLIENT_SECRET: {{salt['cmd.run_stdout']('/usr/local/bin/vault kv get -field=client_secret secret/oauth2/vaultwarden',
                                                          env={'VAULT_ADDR': 'https://vault.service.consul:8200/',
                                                               'VAULT_TOKEN': pillar['dynamicsecrets']['vaultwarden-oidc-reader-token']})}}
        - extra_hosts:
            - "{{pillar['postgresql']['smartstack-hostname']}}:{{pillar['docker']['bridge-ip']}}"
        - require:
            - cmd: vaultwarden-sync-postgres
            - cmd: vaultwarden-sync-oidc
            - cmd: vaultwarden-sync-vault
            - file: vaultwarden-data
        - require_in:
            - cmd: vaultwarden-sync


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
