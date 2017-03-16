rsyslog:
    pkg.installed: []
    service.running:
        - sig: rsyslogd
        - enable: True
        - watch:
            - file: /etc/rsyslog.d*


/etc/rsyslog.d:
    file.directory:
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
