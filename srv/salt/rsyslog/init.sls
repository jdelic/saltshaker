rsyslog:
    pkg.installed: []
    service.running:
        - sig: rsyslogd
        - enable: True
        - watch:
            - file: /etc/rsyslog.d*
