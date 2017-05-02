
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
                  )}}/{{pillar.get('powerdns', {}).get('bitmask', 32)}}


pdns-recursor-lua-config:
    file.managed:
        - name: /etc/powerdns/config.lua
        - contents: |
            addNTA("consul", ".consul is not DNSSEC signed as its Consul's local DNS API")
        - user: root
        - group: root
        - mode: '0644'


pnds-recursor-override-resolv.conf:
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
            - file: pnds-recursor-override-resolv.conf
        - require:
            - file: pnds-recursor-override-resolv.conf


pdns-recursor-service:
    service.running:
        - name: pdns-recursor
        - sig: /usr/sbin/pdns_recursor
        - enable: True
        - order: 10  # see ORDER.md
        - watch:
            - file: pnds-recursor-override-resolv.conf
            - file: pdns-recursor-config
            - file: pdns-recursor-lua-config
        - require:
            - pkg: pdns-recursor
