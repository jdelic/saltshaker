
qmail-delivery-service-link:
    file.symlink:
        - name: {{pillar['mail-delivery']['service-link']}}
        - target: {{pillar['mail-delivery']['service-dir']}}
        - require:
            - file: qmail-delivery-service-run
            - file: qmail-service-folders
            - file: qmail-delivery-service-log-run

qmail-delivery-service-run:
    file.managed:
        - name: {{pillar['mail-delivery']['service-dir']}}/run
        - source: salt://djb/qmail/services/run-delivery
        - template: jinja
        - mode: 750
        - require:
            - file: qmail-service-folders


qmail-delivery-service-log-run:
    file.managed:
        - name: {{pillar['mail-delivery']['service-dir']}}/log/run
        - source: salt://djb/qmail/services/run-log
        - mode: 750
        - require:
            - file: qmail-service-folders
            - file: qmail-delivery-service-log-main


qmail-delivery-service-log-main:
    file.directory:
        - name: {{pillar['mail-delivery']['service-dir']}}/log/main
        - user: qmaild
        - group: root
        - makedirs: True


# vim: syntax=yaml

