
# the maurus.net email system for qmail. This includes
# nixspam, spamassassin and the mailsystem helper scripts


smtpgreeting:
    file.managed:
        - name: /var/qmail/control/smtpgreeting
        - source: salt://mn/mail/smtpgreeting.tpl
        - user: root
        - group: root
        - mode: '644'
        - template: jinja
        - makedirs: True


nixspam:
    file.managed:
        - name: /secure/email/nixspam.skel
        - source: salt://mn/mail/nixspam.skel
        - require:
            - file: email-storage


nixspam-data-directory:
    file.directory:
        - name: /var/lib/nixspam
        - user: virtmail
        - group: mail
        - dir_mode: '755'
        - makedirs: True
        - require:
            - user: virtmail


spamassassin:
    pkg.installed:
        - pkgs:
            - spamassassin
            - spamc
            - procmail
    service.running:
        - sig: spamd
        - enable: True
        - require:
            - pkg: spamassassin


git:
    pkg.installed


mn-mailsystem:
    cmd.script:
        - source: salt://mn/mail/install.sh
        - cwd: /usr/local
        - runas: root
        - require:
            - user: virtmail
            - pkg: git
        - unless: test -e /usr/local/mail/checkdomainpasswd
    pkg.installed:
        - pkgs:
            - python-gdbm
            - libcdb-file-perl


checkdomainpasswd-setuid-binary:
    file.managed:
        - name: /usr/local/mail/checkdomainpasswd
        - user: virtmail
        - group: mail
        - mode: '4755'
        - create: False
        - require:
           - cmd: mn-mailsystem


checkdomainpasswd-script:
    file.managed:
        - name: /usr/local/mail/checkdomainpasswd.py
        - user: virtmail
        - group: mail
        - mode: '750'
        - create: False
        - require:
            - cmd: mn-mailsystem


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


checkvalidrcptto-daily-cron:
    file.managed:
        - name: /etc/cron.daily/checkvalidrcptto
        - source: salt://mn/mail/cron/checkvalidrcptto.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'


webfilters-directory:
    file.directory:
        - name: /secure/webfilters
        - user: horde
        - group: mail
        - dir_mode: '750'
        - makedirs: True
        - require:
           - user: horde
           - file: secure-mount


horde:
    user.present:
        - gid: mail
        - home: /secure/webfilters
        - createhome: False
        - shell: /bin/false
        - require:
            - file: secure-mount


# vim: syntax=yaml

