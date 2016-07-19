
include:
    - dev.concourse.install


concourse-server:
    file.managed:
        - name: /etc/systemd/system/concourse-web.service
        - source: salt://dev/concourse/concourse.jinja.service
        - template: jinja
        - user: root
        - group: root
        - context:
            - type: web
            # postgresql on 127.0.0.1 works because there is haproxy@internal proxying it
            - arguments: >
                --basic-auth-username sysop
                --basic-auth-password {{pillar['dynamicpasswords']['concourse-sysop']}}
                --session-signing-key /etc/concourse/private/session_signing_key.pem
                --tsa-host-key /etc/concourse/private/host_key.pem
                --tsa-authorized-keys /etc/concourse/authorized_worker_keys
                --postgres-data-source postgres://concourse:{{pillar['dynamicpasswords']['concourse-db']}}@127.0.0.1:5432/concourse
                --external-url {{pillar['hostnames']['ci']['protocol']}}://{{pillar['hostnames']['ci']['domain']}}
        - require:
            - file: concourse-install
    service.running:
        - name: concourse-web
        - sig: /usr/local/bin/concourse web
        - enable: True
        - require:
            - file: concourse-server


# vim: syntax=yaml
