
include:
    - dev.concourse.install


concourse-worker-dir:
    file.directory:
        - name: /srv/concourse-worker/
        - user: concourse
        - group: concourse
        - mode: '0755'
        - require:
            - user: concourse-user


concourse-worker:
    file.managed:
        - name: /etc/systemd/system/concourse-worker.service
        - source: salt://dev/concourse/concourse.jinja.service
        - template: jinja
        - user: root
        - group: root
        - context:
            type: worker
            # tsa-host on 127.0.0.1 works because there is haproxy@internal proxying it
            arguments: >
                --work-dir /srv/concourse-worker
                --tsa-host 127.0.0.1
                --tsa-public-key /etc/concourse/host_key.pem.pub
                --external-url {{pillar['hostnames']['ci']['protocol']}}://{{pillar['hostnames']['ci']['domain']}}
        - require:
            - file: concourse-install
            - file: concourse-worker-dir
    service.running:
        - name: concourse-worker
        - sig: /usr/local/bin/concourse web
        - enable: True
        - require:
            - file: concourse-worker


# vim: syntax=yaml
