# we use ssmtp to route mail to a network-internal smart host via smartstack

ssmtp:
    pkg.installed


ssmtp-config:
    file.managed:
        - name: /etc/ssmtp/ssmtp.conf
        - source: salt://ssmtp/ssmtp.jinja.conf
        - template: jinja
