#
# BASICS: iptables is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

ssl-cert:
    group.present


ssl-cert-location:
    file.directory:
        - name: {{pillar['ssl']['certificate-location']}}
        - user: root
        - group: root
        - mode: 755
        - makedirs: True


ssl-key-location:
    file.directory:
        - name: {{pillar['ssl']['secret-key-location']}}
        - user: root
        - group: ssl-cert
        - mode: 710
        - makedirs: True


maurusnet-ca-root-certificate:
    file.managed:
        - name: /usr/share/ca-certificates/local/maurusnet-rootca.crt
        - source: salt://ssl/maurusnet-rootca.crt
        - user: root
        - group: root
        - mode: 755
        - makedirs: True


maurusnet-ca-intermediate-certificate:
    file.managed:
            - name: /usr/share/ca-certificates/local/maurusnet-minionca.crt
            - source: salt://ssl/maurusnet-minionca.crt
            - user: root
            - group: root
            - mode: 755
            - makedirs: True

# vim: syntax=yaml
