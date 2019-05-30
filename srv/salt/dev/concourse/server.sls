
include:
    - dev.concourse.install
    - dev.concourse.sync
    - vault.sync
    - powerdns.sync
    - haproxy.sync
    - consul.sync


concourse-keys-session_signing_key:
    file.managed:
        - name: /etc/concourse/private/session_signing_key.pem
        - contents_pillar: dynamicsecrets:concourse-signingkey:key
        - user: concourse
        - group: concourse
        - mode: '0600'
        - replace: False
        - require_in:
            - service: concourse-server


concourse-keys-host_key-public-copy:
    file.managed:
        - name: /etc/concourse/private/host_key.pem.pub
        - contents_pillar: dynamicsecrets:concourse-hostkey:public
        - user: concourse
        - group: concourse
        - mode: '0644'
        - replace: True
        - require:
            - user: concourse-user
        - require_in:
            - service: concourse-server


concourse-keys-host_key:
    file.managed:
        - name: /etc/concourse/private/host_key.pem
        - contents_pillar: dynamicsecrets:concourse-hostkey:key
        - user: concourse
        - group: concourse
        - mode: '0600'
        - replace: True
        - require:
            - file: concourse-keys-host_key-public-copy
            - file: concourse-keys-host_key-public
            - user: concourse-user
        - require_in:
            - service: concourse-server


authorized_worker_keys-must-exist:
    file.managed:
        - name: /etc/concourse/authorized_worker_keys
        - create: True
        - replace: False
        - allow_empty: True
        - require:
            - file: concourse-config-folder


authorized_worker_keys-template:
    file.managed:
        - name: /etc/concourse/authorized_worker_keys.ctmpl
        - source: salt://dev/concourse/authorized_worker_keys.ctmpl
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: concourse-config-folder


# create a consul template watch for authorized_worker_keys to populate it from the consul KV store
concourse-authorized-key-consul-template-watcher:
    file.managed:
        - name: /etc/consul/template.d/concourse-worker-registration.conf
        - contents: >
            template {
                source = "/etc/concourse/authorized_worker_keys.ctmpl"
                destination = "/etc/concourse/authorized_worker_keys"
                command = "systemctl restart concourse-web"
                perms = 0644
            }
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: authorized_worker_keys-template


concourse-server-envvars{% if pillar['ci'].get('use-vault', True) %}-template{% endif %}:
    file.managed:
    {% if pillar['ci']['use-vault'] %}
        - name: /etc/concourse/envvars-web.tpl
    {% else %}
        - name: /etc/concourse/envvars-web  # read by concourse.service using systemd's `EnvironmentFile=`
    {% endif %}
        - user: root
        - group: root
        - mode: '0600'
        - contents: |
            CONCOURSE_MAIN_TEAM_LOCAL_USER="sysop"
            CONCOURSE_ADD_LOCAL_USER="sysop:{{pillar['dynamicsecrets']['concourse-sysop']}}"
            CONCOURSE_POSTGRES_HOST="{{pillar['postgresql']['smartstack-hostname']}}"
            CONCOURSE_POSTGRES_PORT="5432"
            CONCOURSE_POSTGRES_USER="concourse"
            CONCOURSE_POSTGRES_PASSWORD="{{pillar['dynamicsecrets']['concourse-db']}}"
            CONCOURSE_POSTGRES_SSLMODE="{{pillar['ci']['verify-database-ssl']}}"
            CONCOURSE_POSTGRES_CA_CERT="{{pillar['ssl']['service-rootca-cert'] if
                                          pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
                                          else pillar['postgresql']['pinned-ca-cert']}}"
            CONCOURSE_POSTGRES_DATABASE="concourse"
            CONCOURSE_ENCRYPTION_KEY="{{pillar['dynamicsecrets']['concourse-encryption']}}"
            CONCOURSE_COOKIE_SECURE=true

{%- if pillar['ci'].get('use-vault', True) %}
            CONCOURSE_VAULT_URL="https://{{pillar['vault']['smartstack-hostname']}}:8200/"
            CONCOURSE_VAULT_CA_CERT="{{pillar['ssl']['service-rootca-cert']}}"
            CONCOURSE_VAULT_AUTH_BACKEND="approle"
            CONCOURSE_VAULT_AUTH_PARAM="role_id:{{pillar['dynamicsecrets']['concourse-role-id']}},secret_id:((secret_id))"
            CONCOURSE_OAUTH_DISPLAY_NAME="SSO Account"
            CONCOURSE_OAUTH_CLIENT_ID="((oauth2_client_id))"
            CONCOURSE_OAUTH_CLIENT_SECRET="((oauth2_client_secret))"
            CONCOURSE_OAUTH_AUTH_URL="https://{{pillar['authserver']['hostname']}}/o2/authorize/"
            CONCOURSE_OAUTH_TOKEN_URL="https://{{pillar['authserver']['hostname']}}/o2/token/"
            CONCOURSE_OAUTH_USERINFO_URL="https://{{pillar['authserver']['hostname']}}/o2/fake-userinfo/"
            CONCOURSE_OAUTH_GROUPS_KEY="groups"


concourse-server-envvars:
    cmd.run:
        - name: /bin/true concourse-server-envvars


concourse-server-envvars-approle:
    cmd.run:
        - name: >-
            touch /etc/concourse/envtmp;
            chmod 600 /etc/concourse/envtmp;
            sed "s#((secret_id))#$(/usr/local/bin/vault write -f -format=json auth/approle/role/concourse/secret-id | \
                jq -r .data.secret_id)#"  /etc/concourse/envvars-web.tpl >/etc/concourse/envtmp
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['approle-auth-token']}}
        - unless: >-
            test -f /etc/concourse/envvars-web &&
            source /etc/concourse/envvars-web &&
            echo $CONCOURSE_VAULT_AUTH_PARAM | cut -d',' -f2 | cut -d'=' -f2 | \
                vault write auth/approle/login role_id={{pillar['dynamicsecrets']['concourse-role-id']}} secret_id=- &&
            test $? -eq 0
        - require:
            - file: concourse-server-envvars-template
            - cmd: powerdns-sync
            - cmd: concourse-sync-vault
        - require_in:
            - cmd: concourse-server-envvars


concourse-server-envvars-oauth2:
    cmd.run:
        - name: >-
            touch /etc/concourse/envvars-web;
            chmod 600 /etc/concourse/envvars-web;
            sed "s#((oauth2_client_id))#$(/usr/local/bin/vault read -format=json secret/oauth2/concourse | \
                jq -r .data.client_id)#" /etc/concourse/envtmp | \
            sed "s#((oauth2_client_secret))#$(/usr/local/bin/vault read -format=json secret/oauth2/concourse | \
                jq -r .data.client_secret)#" > /etc/concourse/envvars-web;
            rm /etc/concourse/envtmp
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['concourse-oauth2-read']}}
        - onlyif: test -f /etc/concourse/envtmp
        - unless:
            test -f /etc/concourse/envvars-web &&
            source /etc/concourse/envvars-web &&
            test "$CONCOURSE_OAUTH_CLIENT_ID" == "$(vault read -format=json secret/oauth2/concourse | \
                jq -r .data.client_id)" &&
            test "$CONCOURSE_OAUTH_CLIENT_SECRET" == "$(vault read -format=json secret/oauth2/concourse | \
                jq -r .data.client_secret)"
        - require:
            - cmd: concourse-server-envvars-approle
            - cmd: concourse-sync-oauth2
        - require_in:
            - cmd: concourse-server-envvars
{% endif %}


concourse-server:
    systemdunit.managed:
        - name: /etc/systemd/system/concourse-web.service
        - source: salt://dev/concourse/concourse.jinja.service
        - template: jinja
        - user: root
        - group: root
        - context:
            type: web
            user: concourse
            group: concourse
            # postgresql on 127.0.0.1 works because there is haproxy@internal proxying it
            arguments: >
                --bind-ip {{pillar.get('concourse-server', {}).get('atc-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()])}}
                --bind-port {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
                --session-signing-key /etc/concourse/private/session_signing_key.pem
                --tsa-bind-ip {{pillar.get('concourse-server', {}).get('tsa-internal-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()])}}
                --tsa-bind-port {{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
                --tsa-host-key /etc/concourse/private/host_key.pem
                --tsa-authorized-keys /etc/concourse/authorized_worker_keys
                --external-url {{pillar['ci']['protocol']}}://{{pillar['ci']['hostname']}}
                --tsa-peer-address {{pillar.get('concourse-server', {}).get('atc-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()])}}
            environment_files:
                - /etc/concourse/envvars-web
        - require:
            - file: concourse-install
            - file: authorized_worker_keys-must-exist
    service.running:
        - name: concourse-web
        - sig: /usr/local/bin/concourse_linux_amd64 web
        - enable: True
        - watch:
            - systemdunit: concourse-server
            - file: concourse-install  # restart on a change of the binary
            - concourse-server-envvars  # can be cmd or file
            - file: concourse-servicedef-tsa
            - file: concourse-servicedef-atc-internal
            - file: concourse-servicedef-atc
            - file: concourse-keys-session_signing_key
    cmd.run:
        - name: >
            until test ${count} -gt 60; do
                if curl -s --fail {{pillar['ci']['protocol']}}://{{pillar['ci']['hostname']}}/api/v1/info; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 60
        - env:
            count: 0
        - onchanges:
            - service: concourse-web
        - require:
            - cmd: consul-template-sync
            - cmd: smartstack-sync
        - require_in:
            - cmd: concourse-sync


concourse-servicedef-tsa:
    file.managed:
        - name: /etc/consul/services.d/concourse-tsa.json
        - source: salt://dev/concourse/consul/concourse.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: internal
            suffix: tsa
            mode: tcp
            ip: {{pillar.get('concourse-server', {}).get('tsa-internal-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()])}}
            port: {{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
        - require:
            - systemdunit: concourse-server
            - file: consul-service-dir


# needed because of https://github.com/concourse/concourse/issues/549
concourse-servicedef-atc-internal:
    file.managed:
        - name: /etc/consul/services.d/concourse-atc-internal.json
        - source: salt://dev/concourse/consul/concourse.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: internal
            suffix: atc-internal
            mode: http
            ip: {{pillar.get('concourse-server', {}).get(
                    'atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()]
                )}}
            port: {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - require:
            - systemdunit: concourse-server
            - file: consul-service-dir


concourse-servicedef-atc:
    file.managed:
        - name: /etc/consul/services.d/concourse-atc.json
        - source: salt://dev/concourse/consul/concourse.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: external
            protocol: {{pillar['ci']['protocol']}}
            suffix: atc
            mode: http
            ip: {{pillar.get('concourse-server', {}).get(
                    'atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()]
                )}}
            port: {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
            hostname: {{pillar['ci']['hostname']}}
        - require:
            - systemdunit: concourse-server
            - file: consul-service-dir


fly-link-teams:
    file.managed:
        - name: /etc/concourse/flyhelper.sh
        - source: salt://dev/concourse/helpers/flyhelper.sh
        - user: root
        - group: root
        - mode: '0700'
    cmd.run:
        - name: >
            /etc/concourse/flyhelper.sh set developers developers
        - unless:
            /etc/concourse/flyhelper.sh check developers developers
        - env:
            CONCOURSE_SYSOP_PASSWORD: {{pillar['dynamicsecrets']['concourse-sysop']}}
            CONCOURSE_URL: {{pillar['ci']['protocol']}}://{{pillar['ci']['hostname']}}
        - require:
            - cmd: concourse-sync
            - file: fly-link-teams
            - file: fly-install


concourse-tcp-in{{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar.get('concourse-server', {}).get('tsa-internal-ip',
                           grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                               'internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


concourse-tcp-in{{pillar.get('concourse-server', {}).get('atc-port', 8080)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar.get('concourse-server', {}).get('atc-ip',
                           grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                               'internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# allow us to talk to others
concourse-tcp-out{{pillar.get('concourse-server', {}).get('atc-port', 8080)}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - source: {{pillar.get('concourse-server', {}).get('atc-ip',
                      grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                          'internal-ip-index', 0)|int()])}}
        - sport: {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - destination: '0/0'
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
