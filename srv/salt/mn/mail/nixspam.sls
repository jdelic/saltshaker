
nixspam:
    file.managed:
        - name: /secure/email/nixspam.skel
        - source: salt://mn/mail/nixspam.skel
        - require:
            - file: email-storage
            - pkg: procmail


nixspam-data-directory:
    file.directory:
        - name: /var/lib/nixspam
        - user: virtmail
        - group: mail
        - dir_mode: '755'
        - makedirs: True
        - require:
            - user: virtmail


nixspam-crontab:
    file.managed:
        - name: /etc/cron.d/nixspam
        - source: salt://mn/mail/cron/nixspam
        - user: root
        - group: root
        - mode: '644'


removespam-daily-cron:
    file.managed:
        - name: /etc/cron.daily/removespam
        - source: salt://mn/mail/cron/removespam.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'


# vim: syntax=yaml
