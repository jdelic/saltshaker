rsyslog:
    pkg.installed: []
    service.running:
        - sig: rsyslogd
        - enable: True
        - watch:
            - file: /etc/rsyslog.d*
            - file: /etc/rsyslog.conf


/etc/rsyslog.d:
    file.directory:
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


/etc/rsyslog.d/10-main.conf:
    file.managed:
        - source: salt://basics/rsyslog/10-main.conf
        - user: root
        - group: root
        - mode: '0640'
        - require:
            - file: /etc/rsyslog.d


/etc/rsyslog.conf:
    file.managed:
        - source: salt://basics/rsyslog/rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: rsyslog


# TODO: figure out if salt-master/minion should use rsyslog instead of file logging
#       The config below breaks logging with the Debian-packaged Salt as salt-master runs
#       as root and won't have access to /var/log/salt once salt-log-dir runs.
#salt-log-dir:
#    file.directory:
#        - name: /var/log/salt
#        - makedirs: True
#        - user: salt
#        - group: adm
#        - mode: '2740'


#salt-master-logging:
#    file.managed:
#        - name: /etc/rsyslog.d/40-salt-master.conf
#        - source: salt://basics/rsyslog/40-salt.rsyslog.jinja.conf
#        - template: jinja
#        - context:
#            source: master
#        - require:
#            - file: /etc/rsyslog.d


#salt-minion-logging:
#    file.managed:
#        - name: /etc/rsyslog.d/40-salt-minion.conf
#        - source: salt://basics/rsyslog/40-salt.rsyslog.jinja.conf
#        - template: jinja
#        - context:
#            source: minion
#        - require:
#            - file: /etc/rsyslog.d
