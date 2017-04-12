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


salt-log-dir:
    file.directory:
        - name: /var/log/salt
        - makedirs: True
        - user: root
        - group: adm
        - mode: '2740'


salt-master-logging:
    file.managed:
        - name: /etc/rsyslog.d/40-salt-master.conf
        - source: salt://rsyslog/40-salt.rsyslog.jinja.conf
        - template: jinja
        - context:
            source: master
        - require:
            - file: /etc/rsyslog.d


salt-minion-logging:
    file.managed:
        - name: /etc/rsyslog.d/40-salt-minion.conf
        - source: salt://rsyslog/40-salt.rsyslog.jinja.conf
        - template: jinja
        - context:
            source: minion
        - require:
            - file: /etc/rsyslog.d
