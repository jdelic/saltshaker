
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
            - secure-mount  # this is legal since 2016.3
