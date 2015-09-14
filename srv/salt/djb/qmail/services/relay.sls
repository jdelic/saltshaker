
qmail-smtpd-relay-service-link:
    file.symlink:
        - target: {{pillar['smtp']['relay-service-dir']}}
        - name: {{pillar['smtp']['relay-service-link']}}
        - require:
            - file: qmail-smtpd-relay-service-config
            - file: qmail-smtpd-relay-service-run
            - file: qmail-smtpd-relay-service-log-run
            - cmd:  qmail-smtpd-relay-service-tcp


# allow others to contact us on port 25
qmail-smtpd-relay-in25-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar['smtp'].get('relay-ip', grains['ip_interfaces'][pillar['ifassign']['external-alt']][pillar['ifassign'].get('external-alt-ip-index', 0)|int()])}}
        - dport: 25
        - proto: tcp
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables


{% for port in ['25', '465'] %}
# allow us to contact others on ports
qmail-smtpd-relay-out{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - proto: tcp
        - source: {{pillar['smtp'].get('relay-ip', grains['ip_interfaces'][pillar['ifassign']['external-alt']][pillar['ifassign'].get('external-alt-ip-index', 0)|int()])}}
        - destination: '0/0'
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables
{% endfor %}


qmail-smtpd-relay-service-config:
    file.managed:
        - name: {{pillar['smtp']['relay-service-dir']}}/config
        - source: salt://djb/qmail/services/config-relay
        - template: jinja
        - require:
            - file: qmail-service-folders

qmail-smtpd-relay-service-run:
    file.managed:
        - name: {{pillar['smtp']['relay-service-dir']}}/run
        - source: salt://djb/qmail/services/run
        - mode: 750
        - require:
            - file: qmail-service-folders


qmail-smtpd-relay-service-log-run:
    file.managed:
        - name: {{pillar['smtp']['relay-service-dir']}}/log/run
        - source: salt://djb/qmail/services/run-log
        - mode: 750
        - require:
            - file: qmail-service-folders
            - file: qmail-smtpd-relay-service-log-main


qmail-smtpd-relay-service-log-main:
    file.directory:
        - name: {{pillar['smtp']['relay-service-dir']}}/log/main
        - user: qmaild
        - group: root
        - makedirs: True


qmail-smtpd-relay-service-tcp:
    file.managed:
        - name: {{pillar['smtp']['relay-service-dir']}}/tcp
        - source: salt://djb/qmail/services/tcp-relay
        - template: jinja
    cmd.wait:
        - name: /usr/bin/make -f Makefile
        - cwd: {{pillar['smtp']['relay-service-dir']}}
        - watch:
            - file: qmail-smtpd-relay-service-tcp
        - require:
            - file: {{pillar['smtp']['relay-service-dir']}}/tcp
            - file: qmail-smtpd-relay-service-Makefile
            - file: qmail-service-folders


qmail-smtpd-relay-service-Makefile:
    file.managed:
        - name: {{pillar['smtp']['relay-service-dir']}}/Makefile
        - source: salt://djb/qmail/services/Makefile
        - require:
            - file: qmail-service-folders


qmail-smtpd-relay-consul-servicedef:
    file.managed:
        - name: /etc/consul/services.d/qmail-smtpd-relay.json
        - source: salt://djb/qmail/services/consul/relay.json
        - mode: '0644'
        - template: jinja
        - require:
            - file: consul-service-dir

# vim: syntax=yaml
