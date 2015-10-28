
# the maurus.net email system for qmail. This includes
# nixspam, spamassassin and the mailsystem helper scripts


/var/qmail/control/smtpgreeting:
    file.managed:
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


/var/lib/nixspam:
    file.directory:
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
        - user: root
        - group: root
        - require:
            - user: virtmail
            - pkg: git
        - unless: test -e /usr/local/mail/checkdomainpasswd
    pkg.installed:
        - pkgs:
            - python-gdbm
            - libcdb-file-perl


/usr/local/mail/checkdomainpasswd:
    file.managed:
        - user: virtmail
        - group: mail
        - mode: '4755'
        - create: False
        - require:
           - cmd: mn-mailsystem


/usr/local/mail/checkdomainpasswd.py:
    file.managed:
        - user: virtmail
        - group: mail
        - mode: '750'
        - create: False
        - require:
            - cmd: mn-mailsystem


/etc/cron.d/nixspam:
    file.managed:
        - source: salt://mn/mail/cron/nixspam
        - user: root
        - group: root
        - mode: '644'


/etc/cron.daily/removespam:
    file.managed:
        - source: salt://mn/mail/cron/removespam.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'


/etc/cron.daily/checkvalidrcptto:
    file.managed:
        - source: salt://mn/mail/cron/checkvalidrcptto.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: '750'


/secure/webfilters:
    file.directory:
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

