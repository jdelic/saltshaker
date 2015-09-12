
qmail-smtpd-internal-relay-service-link:
    file.symlink:
        - target: {{pillar['smtp']['internal-relay-service-dir']}}
        - name: {{pillar['smtp']['internal-relay-service-link']}}
        - require:
            - file: qmail-smtpd-internal-relay-service-config
            - file: qmail-smtpd-internal-relay-service-run
            - file: qmail-smtpd-internal-relay-service-log-run
            - cmd:  qmail-smtpd-internal-relay-service-tcp


# allow others to contact us on the internal interface
qmail-smtpd-internal-relay-in25-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 25
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


qmail-smtpd-internal-relay-service-config:
    file.managed:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/config
        - source: salt://djb/qmail/services/config-internal-relay
        - template: jinja
        - require:
            - file: qmail-service-folders


qmail-smtpd-internal-relay-service-run:
    file.managed:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/run
        - source: salt://djb/qmail/services/run
        - mode: 750
        - require:
            - file: qmail-service-folders


qmail-smtpd-internal-relay-service-log-run:
    file.managed:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/log/run
        - source: salt://djb/qmail/services/run-log
        - mode: 750
        - require:
            - file: qmail-service-folders
            - file: qmail-smtpd-internal-relay-service-log-main


qmail-smtpd-internal-relay-service-log-main:
    file.directory:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/log/main
        - user: qmaild
        - group: root
        - makedirs: True


qmail-smtpd-internal-relay-service-tcp:
    file.managed:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/tcp
        - source: salt://djb/qmail/services/tcp-internal-relay
        - template: jinja
    cmd.wait:
        - name: /usr/bin/make -f Makefile
        - cwd: {{pillar['smtp']['internal-relay-service-dir']}}
        - watch:
            - file: qmail-smtpd-internal-relay-service-tcp
        - require:
            - file: {{pillar['smtp']['internal-relay-service-dir']}}/tcp
            - file: qmail-smtpd-internal-relay-service-Makefile
            - file: qmail-service-folders


qmail-smtpd-internal-relay-service-Makefile:
    file.managed:
        - name: {{pillar['smtp']['internal-relay-service-dir']}}/Makefile
        - source: salt://djb/qmail/services/Makefile
        - require:
            - file: qmail-service-folders


qmail-smtpd-internal-relay-consul-servicedef:
    file.managed:
        - name: /etc/consul/services.d/qmail-smtpd-internal-relay.json
        - source: salt://djb/qmail/services/consul/internal-relay.json
        - mode: '0644'
        - template: jinja
        - require:
            - file: consul-data-dir

# vim: syntax=yaml
