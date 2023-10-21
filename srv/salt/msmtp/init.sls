# we use msmtp to route mail to a network-internal smart host via smartstack

include:
    - basics.noexim

msmtp:
    pkg.installed:
        - require:
            - pkg: no-exim


msmtp-config:
    file.managed:
        - name: /etc/msmtprc
        - source: salt://msmtp/msmtprc.jinja
        - template: jinja

