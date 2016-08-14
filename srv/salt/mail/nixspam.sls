
nixspam-procmail-include:
    file.managed:
        - name: {{pillar['emailstore']['path']}}/nixspam.global.procmailrc
        - source: salt://mail/nixspam.global.procmailrc


nixspam:
    file.managed:
        - name: {{pillar['emailstore']['path']}}/nixspam.skel
        - source: salt://mail/nixspam.skel
        - require:
            - file: email-storage
            - file: nixspam-procmail-include
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
        - source: salt://mail/cron/nixspam
        - user: root
        - group: root
        - mode: '644'


removespam-daily-cron:
    file.managed:
        - name: /etc/cron.daily/removespam
        - source: salt://mail/cron/removespam.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'


# vim: syntax=yaml
