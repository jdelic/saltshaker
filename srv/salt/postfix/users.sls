

{% set qmail_groups = ['nofiles', 'ssl-cert', 'mail'] %}
# postfix groups
{% for group in qmail_groups %}
{{group}}:
    group.present
{% endfor %}

# postfix users
alias:
    user.present:
        - uid: 64010  # as reserved in Debian base-passwd
        - gid: nofiles
        - groups:
            - nofiles
        - home: /etc/postfix/alias
        - createhome: False
        - shell: /bin/sh
        - require:
            - group: nofiles


virtmail:
    user.present:
        - gid: mail
        - groups:
            - mail
        - home: /secure/email
        - createhome: False
        - shell: /bin/false
        - require:
            - group: mail
            - file: secure-mount

