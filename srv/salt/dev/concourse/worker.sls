
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
            user: root  # worker must be run as root as it orchestrates containers (see concourse CI docs)
            group: root
            # tsa-host on 127.0.0.1 works because there is haproxy@internal proxying it
            arguments: >
                --work-dir /srv/concourse-worker
                --tsa-host 127.0.0.1
                --tsa-public-key /etc/concourse/host_key.pub
        - require:
            - file: concourse-install
            - file: concourse-worker-dir
    service.running:
        - name: concourse-worker
        - sig: /usr/local/bin/concourse worker
        - enable: True
        - require:
            - file: concourse-worker
        - watch:
            - file: concourse-worker
            - file: concourse-install  # restart on a change of the binary


# vim: syntax=yaml
