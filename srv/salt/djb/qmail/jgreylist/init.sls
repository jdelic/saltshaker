
/var/qmail/jgreylist:
    file.directory:
        - user: qmaild
        - group: ssl-cert
        - mode: 700
        - require:
            - user: qmaild
            - group: ssl-cert
            - file: /var/qmail

/var/qmail/bin/jgreylist:
    file.managed:
        - source: salt://djb/qmail/jgreylist/jgreylist
        - mode: 755
        - require:
            - file: /var/qmail

/var/qmail/bin/jgreylist-clean:
    file.managed:
        - source: salt://djb/qmail/jgreylist/jgreylist-clean
        - mode: 755
        - require:
            - file: /var/qmail

# vim: syntax=yaml

