include:
    - vaultwarden.sync

{% set ip = pillar.get('vaultwarden', {}).get('webdav', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            ) %}

{% set port = pillar.get('vaultwarden', {}).get('webdav', {}).get('bind-port', 31080) %}

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
        - ports:
            - "80:{{ip}}:{{port}}"
        - environment:
            - SSO_ENABLED: True
            - SSO_AUTHORITY: https://{{pillar['authserver']['hostname']}}/o2/
            - SMTP_HOST: {{pillar['smtp']['smartstack-hostname']}}
            - SMTP_PORT: 25
            - SMTP_FROM: vaultwarden@{{pillar['vaultwarden']['hostname']}}
            - DATABASE_URL: postgres://vaultwarden:{{pillar['dynamicsecrets']['vaultwarden-db']}}@{{pillar['postgresql']['smartstack-hostname']}}/vaultwarden
            - SSO_CLIENT_ID: vaultwarden
            # TODO!
            - SSO_CLIENT_SECRET: {{pillar['vaultwarden']['oidc-client-secret']}}
        - extra_hosts:
            - "{{pillar['postgresql']['smartstack-hostname']}}:{{pillar['docker']['bridge-ip']}}"
        - volumes:
            - /vw-data:/secure/vaultwarden
        - require:
            - cmd: vaultwarden-sync-postgres
            - cmd: vaultwarden-sync-oidc
            - file: vaultwarden-data
        - require_in:
            - cmd: vaultwarden-sync


vaultwarden-http-tcp-in80-ipv4:
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
