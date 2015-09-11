
{% from 'djb/qmail/users.sls' import qmail_users %}

email-storage:
    file.directory:
        - name: /secure/email
        - user: virtmail
        - group: mail
        - dir_mode: 750
        - makedirs: True
        - require:
            - user: virtmail
            - file: secure-mount

#mailqueue:
#    file.directory:
#        - name: /mailqueue
#        - user: qmailq
#        - group: qmail
#        - dir_mode: 750
#        - makedirs: True


# vim: syntax=yaml

