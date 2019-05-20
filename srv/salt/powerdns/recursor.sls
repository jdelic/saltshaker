
include:
    - powerdns.sync
    - consul.sync


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
            cidrs:
                - {{pillar.get('powerdns', {}).get('bind-ip',
                      grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                          'internal-ip-index', 0
                      )|int()]
                  )}}/{{pillar.get('powerdns', {}).get('bitmask', 32)}}
            {% if pillar.get('ci', False) %}
                - {{pillar.get('ci', {}).get('garden-network-pool',
                      '10.254.0.0/22')}}
            {% endif %}


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
            nameserver 169.254.1.1
        - mode: '0644'
        - user: root
        - group: root
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync


pdns-dhclient-enforce-nameservers:
    file.append:
        - name: /etc/dhcp/dhclient.conf
        - text: |
            supersede domain-name-servers 169.254.1.1;
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync


pdns-recursor-service:
    service.running:
        - name: pdns-recursor
        - sig: /usr/sbin/pdns_recursor
        - enable: True
        - init_delay: 3
        #- order: 10  # see ORDER.md
        - watch:
            - file: pdns-recursor-config
            - file: pdns-recursor-lua-config
        - require:
            - pkg: pdns-recursor
            - cmd: consul-sync
        - require_in:
            - cmd: powerdns-sync
