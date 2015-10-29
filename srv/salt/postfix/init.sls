
include:
    - postfix.users


postfix:
    service:
        - running
        - watch:
            - file: postfix-main-config
            - file: postfix-master-config
        - require:
            - pkg: postfix
            - file: postfix-main-config
            - file: postfix-master-config
        - enable: True

    pkg:
        - installed
        - pkgs:
            - postfix
            - procmail
            - libmail-dkim-perl
            - opendkim
            - opendkim-tools
            - spamassassin
            - spamc


domainkeys-directory:
    file.directory:
        - name: /etc/postfix/domainkeys
        - dir_mode: 700
        - makedirs: True


postfix-main-config:
    file.managed:
        - name: /etc/postfix/main.cf
        - source: salt://postfix/main.cf


postfix-master-config:
    file.managed:
        - name: /etc/postfix/master.cf
        - source: salt://postfix/master.cf

