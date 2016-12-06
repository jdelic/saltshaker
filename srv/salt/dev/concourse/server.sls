
include:
    - dev.concourse.install


# ssh-keygen -t rsa -f session_signing_key -N ''
{% for key in ["worker_key",] %}
concourse-keys-{{key}}:
    cmd.run:
        - name: ssh-keygen -t rsa -f /etc/concourse/private/{{key}}.pem -N ''
        - runas: concourse
        - unless: test -f /etc/concourse/private/{{key}}.pem
        - require:
            - file: concourse-private-config-folder
            - user: concourse-user
    file.managed:
        - name: /etc/concourse/private/{{key}}.pem
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: False
        - require:
            - cmd: concourse-keys-{{key}}
{% endfor %}


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


# concourse requires this file to at least exist, even if empty
concourse-authorized-key-file:
    file.managed:
        - name: /etc/concourse/authorized_worker_keys
        - replace: False
        - user: concourse
        - group: concourse
        - mode: '0640'
        - create: True
        - require:
            - user: concourse-user


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
                --basic-auth-username sysop
                --basic-auth-password {{pillar['dynamicsecrets']['concourse-sysop']}}
                --bind-ip {{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
                --bind-port {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
                --session-signing-key /etc/concourse/private/session_signing_key.pem
                --tsa-bind-ip {{pillar.get('concourse-server', {}).get('tsa-internal-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
                --tsa-bind-port {{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
                --tsa-host-key /etc/concourse/private/host_key.pem
                --tsa-authorized-keys /etc/concourse/authorized_worker_keys
                --postgres-data-source postgres://concourse:{{pillar['dynamicsecrets']['concourse-db']}}@127.0.0.1:5432/concourse
                --external-url {{pillar['ci']['protocol']}}://{{pillar['ci']['hostname']}}
                --peer-url http://{{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}:{{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - use:
            - require-concourse-keys
        - require:
            - file: concourse-install
            - file: concourse-authorized-key-file
    service.running:
        - name: concourse-web
        - sig: /usr/local/bin/concourse web
        - enable: True
        - require:
            - file: concourse-server
        - watch:
            - file: concourse-server
            - file: concourse-install  # restart on a change of the binary


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
            ip: {{pillar.get('concourse-server', {}).get('tsa-internal-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
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
            ip: {{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
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
            ip: {{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
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
        - destination: {{pillar.get('concourse-server', {}).get('tsa-internal-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
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
        - destination: {{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
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
        - source: {{pillar.get('concourse-server', {}).get('atc-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - sport: {{pillar.get('concourse-server', {}).get('atc-port', 8080)}}
        - destination: '0/0'
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
