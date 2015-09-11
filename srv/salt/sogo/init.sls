
sogo:
# SOGO is now part of Debian Jessie
#    pkgrepo.managed:
#        - humanname: SOGo Debian
#        - name: deb http://inverse.ca/debian jessie jessie
#        - file: /etc/apt/sources.list.d/sogo.list
#        - key_url: salt://sogo/sogo_810273C4.pgp.key
#        - require_in:
#            - pkg: sogo
    pkg.installed:
        - name: sogo
        - require:
            - file: sogo.preferences
    service:
        - running
        - enable: True
        - sig: /usr/sbin/sogod
        - require:
            - pkg: sogo


sogo.preferences:
    file.managed:
        - name: /etc/apt/preferences.d/sogo
        - source: salt://sogo/preferences.d/sogo

# vim: syntax=yaml
