
include:
    - dev.concourse.install


# ssh-keygen -t rsa -f session_signing_key -N ''
{% for key in ["worker_key" "session_signing_key"] %}
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


concourse-keys-host_key-public-copy:
    file.managed:
        - name: /etc/concourse/private/host_key.pem.pub
        - contents_pillar: ssh:concourse:public
        - user: concourse
        - group: concourse
        - mode: '0644'
        - replace: True


concourse-keys-host_key:
    file.managed:
        - name: /etc/concourse/private/host_key.pem
        - contents_pillar: ssh:concourse:key
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: True
        - require:
            - file: concourse-keys-host_key-public-copy
            - file: concourse-keys-host_key-public


require-concourse-keys:
    test.nop:
        - require:
{% for key in ["host_key", "worker_key" "session_signing_key"] %}
            - file: concourse-keys-{{key}}
{% endfor %}


concourse-server:
    file.managed:
        - name: /etc/systemd/system/concourse-web.service
        - source: salt://dev/concourse/concourse.jinja.service
        - template: jinja
        - user: root
        - group: root
        - context:
            type: web
            # postgresql on 127.0.0.1 works because there is haproxy@internal proxying it
            arguments: >
                --basic-auth-username sysop
                --basic-auth-password {{pillar['dynamicpasswords']['concourse-sysop']}}
                --session-signing-key /etc/concourse/private/session_signing_key.pem
                --tsa-host-key /etc/concourse/host_key.pem
                --tsa-authorized-keys /etc/concourse/authorized_worker_keys
                --postgres-data-source postgres://concourse:{{pillar['dynamicpasswords']['concourse-db']}}@127.0.0.1:5432/concourse
                --external-url {{pillar['hostnames']['ci']['protocol']}}://{{pillar['hostnames']['ci']['domain']}}
        - use:
            - require-concourse-keys
        - require:
            - file: concourse-install
    service.running:
        - name: concourse-server
        - sig: /usr/local/bin/concourse web
        - enable: True
        - require:
            - file: concourse-server


concourse-servicedef:
    file.managed:
        - name: /etc/consul/services.d/concourse.json
        - source: salt://concourse/consul/postgresql.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('concourse-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('concourse-server', {}).get('bind-port', 2222)}}
        - require:
            - file: concourse-server
            - file: consul-service-dir

# vim: syntax=yaml
