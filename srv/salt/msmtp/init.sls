# we use msmtp to route mail to a network-internal smart host via smartstack

include:
    - basics.noexim

msmtp:
    pkg.installed:
        - pkgs:
            - msmtp
            - msmtp-mta
        - require:
            - pkg: no-exim
    service.dead:
        - name: msmtpd
        - enable: False
        - require:
            - pkg: msmtp


msmtp-config:
    file.managed:
        - name: /etc/msmtprc
        - source: salt://msmtp/msmtprc.jinja
        - template: jinja

