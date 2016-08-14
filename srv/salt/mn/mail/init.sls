
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
        - replace: False
        - require:
           - cmd: mn-mailsystem


checkdomainpasswd-script:
    file.managed:
        - name: /usr/local/mail/checkdomainpasswd.py
        - user: virtmail
        - group: mail
        - mode: '750'
        - create: False
        - replace: False
        - require:
            - cmd: mn-mailsystem


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

