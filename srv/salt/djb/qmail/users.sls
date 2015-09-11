

{% set qmail_groups = ['nofiles', 'qmail', 'mail'] %}
# qmail groups
{% for group in qmail_groups %}
{{group}}: 
    group.present{% if group == "qmail" %}:
        - gid: 64010{% endif %}
{% endfor %}

{% set qmail_users = ['alias', 'qmaild', 'qmaill', 'qmailp', 'qmailq', 'qmailr', 'qmails', 'virtmail'] %}
# qmail users
alias:
    user.present:
        - uid: 64010  # as reserved in Debian base-passwd
        - gid: nofiles
        - groups:
            - nofiles
        - home: /var/qmail/alias
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: nofiles

qmaild:
    user.present:
        - uid: 64011
        - gid: ssl-cert
        - groups:
            - qmail
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: ssl-cert
            - group: qmail

qmaill:
    user.present:
        - uid: 64016
        - gid: ssl-cert
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: ssl-cert

qmailp:
    user.present:
        - uid: 64017
        - gid: ssl-cert
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: ssl-cert

qmailq:
    user.present:
        - uid: 64015
        - gid: qmail
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: qmail

qmailr:
    user.present:
        - uid: 64013
        - gid: qmail
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: qmail

qmails:
    user.present:
        - uid: 64012
        - gid: qmail
        - home: /var/qmail
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: qmail

virtmail:
    user.present:
        - gid: mail
        - home: /secure/email 
        - createhome: False
        - shell: /bin/false
        - require:
            - group: mail
            - file: secure-mount

# -* vim: syntax=yaml

