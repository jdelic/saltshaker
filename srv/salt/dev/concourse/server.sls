
include:
    - dev.concourse.install


concourse-server:
    file.managed:
        - name: /etc/systemd
        - require:
            - file: concourse-install
    service.running:
        - name: ...


# vim: syntax=yaml
