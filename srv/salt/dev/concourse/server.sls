
include:
    - dev.concourse.install
    - vault.sync


concourse-keys-session_signing_key:
    file.managed:
        - name: /etc/concourse/private/session_signing_key.pem
        - contents_pillar: dynamicsecrets:concourse-signingkey:key
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: False


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


concourse-keys-host_key:
    file.managed:
        - name: /etc/concourse/private/host_key.pem
        - contents_pillar: dynamicsecrets:concourse-hostkey:key
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: True
        - require:
            - file: concourse-keys-host_key-public-copy
            - file: concourse-keys-host_key-public
            - user: concourse-user


require-concourse-keys:
    test.nop:
        - require:
{% for key in ["host_key", "worker_key", "session_signing_key"] %}
            - file: concourse-keys-{{key}}
{% endfor %}


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


concourse-server-envvars{% if pillar['ci']['use-vault'] %}-template{% endif %}:
    file.managed:
    {% if pillar['ci']['use-vault'] %}
        - name: /etc/concourse/envvars.tpl
    {% else %}
        - name: /etc/concourse/envvars  # read by concourse.service using systemd's `EnvironmentFile=`
    {% endif %}
        - user: root
        - group: root
        - mode: '0600'
        - contents: |
            CONCOURSE_MAIN_TEAM_LOCAL_USER="sysop"
            CONCOURSE_ADD_LOCAL_USER="sysop:{{pillar['dynamicsecrets']['concourse-sysop']}}"
            CONCOURSE_POSTGRES_DATA_SOURCE="postgres://concourse:{{
                pillar['dynamicsecrets']['concourse-db']}}@{{
                pillar['postgresql']['smartstack-hostname']}}:5432/concourse?sslmode={{
                    pillar['ci']['verify-database-ssl']}}&sslrootcert={{pillar['ssl']['service-rootca-cert'] if
                        pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
                        else pillar['postgresql']['pinned-ca-cert']}}"
            CONCOURSE_ENCRYPTION_KEY="{{pillar['dynamicsecrets']['concourse-encryption']}}"
            CONCOURSE_COOKIE_SECURE=true

            {%- if pillar['ci'].get('use-vault', True) %}
            CONCOURSE_VAULT_URL="https://{{pillar['vault']['smartstack-hostname']}}:8200/"
            CONCOURSE_VAULT_CA_CERT="{{pillar['ssl']['service-rootca-cert']}}"
            CONCOURSE_VAULT_AUTH_BACKEND="approle"
            CONCOURSE_VAULT_AUTH_PARAM="role_id={{pillar['dynamicsecrets']['concourse-role-id']}},secret_id=((secret_id))"
concourse-server-envvars:
    cmd.run:
        - name: >-
            sed "s#((secret_id))#$(/usr/local/bin/vault write -f -format=json auth/approle/role/concourse/secret-id | \
                jq -r .data.secret_id)#"  /etc/concourse/envvars.tpl > /etc/concourse/envvars
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['approle-auth-token']}}
        - onchanges:
            - file: concourse-server-envvars-template
        - creates: /etc/concourse/envvars
        - unless: >-
            test -f /etc/concourse/envvars &&
            source /etc/concourse/envvars &&
            echo $CONCOURSE_VAULT_AUTH_PARAM | cut -d',' -f2 | cut -d'=' -f2 | \
                vault write auth/approle/login role_id={{pillar['dynamicsecrets']['concourse-role-id']}} secret_id=- &&
            test $? -eq 0
        - require:
            - file: concourse-server-envvars-template
            - file: vault
            - cmd: vault-sync
            {% endif %}


concourse-server:
    file.managed:
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
                --peer-url http://{{pillar.get('concourse-server', {}).get('atc-ip',
                    grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()])}}:{{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - use:
            - require-concourse-keys
        - require:
            - file: concourse-install
            - file: authorized_worker_keys-must-exist
            - concourse-server-envvars
    service.running:
        - name: concourse-web
        - sig: /usr/local/bin/concourse web
        - enable: True
        - watch:
            - file: concourse-server
            - file: concourse-install  # restart on a change of the binary
            - concourse-server-envvars  # can be cmd of file


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
            - file: concourse-server
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
            - file: concourse-server
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
            - file: concourse-server
            - file: consul-service-dir


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
