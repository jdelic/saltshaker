
include:
    - postfix.users

    
postfix:
    service:
        - running
        - watch:
            - file: /etc/postfix/main.cf
            - file: /etc/postfix/master.cf
        - require:
            - pkg: postfix
            - file: /etc/postfix/main.cf
            - file: /etc/postfix/master.cf
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


/etc/postfix/domainkeys:
    file.directory:
        - dir_mode: 700
        - makedirs: True
        
        
/etc/postfix/main.cf:
    file.managed:
        - source: salt://postfix/main.cf
        
        
/etc/postfix/master.cf:
    file.managed:
        - source: salt://postfix/master.cf
        
