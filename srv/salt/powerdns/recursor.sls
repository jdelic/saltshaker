
pdns-recursor:
    pkg.installed


pdns-recursor-config:
    file.managed:
        - name: /etc/powerdns/recursor.conf
        - source: salt://powerdns/recursor.jinja.conf
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            cidr: {{pillar.get('powerdns', {}).get('bind-ip',
                      grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                          'internal-ip-index', 0
                      )|int()]
                  )}}/{{pillar.get('powerdns', {}).get('bitmask', 24)}}


pdns-recursor-lua-config:
    file.managed:
        - name: /etc/powerdns/config.lua
        - contents: |
            addNTA("consul", ".consul is not DNSSEC signed as its Consul's local DNS API")
        - user: root
        - group: root
        - mode: '0644'


pnds-override-resolv.conf:
    file.managed:
        - name: /etc/resolv.conf
        - contents: |
            nameserver 127.0.0.1
        - mode: '0644'
        - user: root
        - group: root
    cmd.run:
        - name: chattr +i /etc/resolv.conf
        - onchanges:
            - file: pnds-override-resolv.conf
        - require:
            - file: pnds-override-resolv.conf


pdns-service:
    service.running:
        - name: pdns-recursor
        - sig: /usr/sbin/pdns_recursor
        - enable: True
        - watch:
            - file: pnds-override-resolv.conf
            - file: pdns-recursor-config
            - file: pdns-recursor-lua-config
