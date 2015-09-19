
qmail-smtpd-receiver-service-link:
    file.symlink:
        - target: {{pillar['smtp']['receiver-service-dir']}}
        - name: {{pillar['smtp']['receiver-service-link']}}
        - require:
            - file: qmail-smtpd-receiver-service-config
            - file: qmail-smtpd-receiver-service-run
            - file: qmail-smtpd-receiver-service-log-run
            - cmd:  qmail-smtpd-receiver-service-tcp


# allow others to contact us on port 25
qmail-smtpd-receiver-in25-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar['smtp'].get('receiver-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
        - dport: 25
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


qmail-smtpd-receiver-service-config:
    file.managed:
        - name: {{pillar['smtp']['receiver-service-dir']}}/config
        - source: salt://djb/qmail/services/config-receiver
        - template: jinja
        - require:
            - file: qmail-service-folders


qmail-smtpd-receiver-service-run:
    file.managed:
        - name: {{pillar['smtp']['receiver-service-dir']}}/run
        - source: salt://djb/qmail/services/run
        - mode: 750
        - require:
            - file: qmail-service-folders


qmail-smtpd-receiver-service-log-run:
    file.managed:
        - name: {{pillar['smtp']['receiver-service-dir']}}/log/run
        - source: salt://djb/qmail/services/run-log
        - mode: 750
        - require:
            - file: qmail-service-folders
            - file: qmail-smtpd-receiver-service-log-main


qmail-smtpd-receiver-service-log-main:
    file.directory:
        - name: {{pillar['smtp']['receiver-service-dir']}}/log/main
        - user: qmaild
        - group: root
        - makedirs: True


qmail-smtpd-receiver-service-tcp:
    file.managed:
        - name: {{pillar['smtp']['receiver-service-dir']}}/tcp
        - source: salt://djb/qmail/services/tcp-receiver
    cmd.wait:
        - name: /usr/bin/make -f Makefile
        - cwd: {{pillar['smtp']['receiver-service-dir']}}
        - watch:
            - file: qmail-smtpd-receiver-service-tcp
        - require:
            - file: {{pillar['smtp']['receiver-service-dir']}}/tcp
            - file: qmail-smtpd-receiver-service-Makefile
            - file: qmail-service-folders


qmail-smtpd-receiver-service-Makefile:
    file.managed:
        - name: {{pillar['smtp']['receiver-service-dir']}}/Makefile
        - source: salt://djb/qmail/services/Makefile
        - require:
            - file: qmail-service-folders


qmail-smtpd-receiver-consul-servicedef:
    file.managed:
        - name: /etc/consul/services.d/qmail-smtpd-receiver.json
        - source: salt://djb/qmail/services/consul/receiver.json
        - mode: '0644'
        - template: jinja
        - require:
            - file: consul-service-dir


# vim: syntax=yaml

