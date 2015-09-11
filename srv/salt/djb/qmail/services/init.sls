
{% from 'djb/qmail/users.sls' import qmail_users %}

include:
    - djb.qmail.services.relay
    - djb.qmail.services.internal_relay
    - djb.qmail.services.delivery
    - djb.qmail.services.receiver


qmail-service-folders:
    file.directory:
        - user: root
        - group: root
        - dir_mode: 0755
        - makedirs: True
        - names:
            - {{pillar['smtp']['relay-service-dir']}}
            - {{pillar['smtp']['relay-service-dir']}}/log
            - {{pillar['smtp']['relay-service-dir']}}/log/env
            - {{pillar['smtp']['receiver-service-dir']}}
            - {{pillar['smtp']['receiver-service-dir']}}/log
            - {{pillar['smtp']['receiver-service-dir']}}/log/env
            - {{pillar['mail-delivery']['service-dir']}}
            - {{pillar['mail-delivery']['service-dir']}}/log
            - {{pillar['mail-delivery']['service-dir']}}/log/env
            - {{pillar['smtp']['internal-relay-service-dir']}}
            - {{pillar['smtp']['internal-relay-service-dir']}}/log
            - {{pillar['smtp']['internal-relay-service-dir']}}/log/env
        - require:
            - file: /var/qmail
            {% for user in qmail_users %}
            - user: {{user}}
            {% endfor %}


# vim: syntax=yaml

