
jgreylist-data-directory:
    file.directory:
        - name: /var/qmail/jgreylist
        - user: qmaild
        - group: ssl-cert
        - mode: 700
        - require:
            - user: qmaild
            - group: ssl-cert
            - file: var-qmail-directory

jgreylist-binary:
    file.managed:
        - name: /var/qmail/bin/jgreylist
        - source: salt://djb/qmail/jgreylist/jgreylist
        - mode: 755
        - require:
            - file: var-qmail-directory

jgreylist-clean-binary:
    file.managed:
        - name: /var/qmail/bin/jgreylist-clean
        - source: salt://djb/qmail/jgreylist/jgreylist-clean
        - mode: 755
        - require:
            - file: var-qmail-directory

# vim: syntax=yaml

