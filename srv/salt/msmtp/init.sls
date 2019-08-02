# we use msmtp to route mail to a network-internal smart host via smartstack

msmtp:
    pkg.installed


msmtp-config:
    file.managed:
        - name: /etc/msmtprc
        - source: salt://msmtp/msmtprc.jinja
        - template: jinja
