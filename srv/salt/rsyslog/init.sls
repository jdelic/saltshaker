rsyslog:
    pkg.installed: []
    service.running:
        - sig: rsyslogd
        - enable: True
        - reload: True
        - watch:
            - file: /etc/rsyslog.d*
