
spamassassin:
    pkg.installed:
        - pkgs:
            - spamassassin
            - spamc
        - install_recommends: False
    service.running:
        - sig: spamd
        - enable: True
        - require:
            - pkg: spamassassin


removespam-daily-cron:
    file.managed:
        - name: /etc/cron.daily/removespam
        - source: salt://mail/cron/removespam.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'

# vim: syntax=yaml
