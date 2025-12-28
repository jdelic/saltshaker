
include:
    - powerdns.sync
    - consul.sync


pdns-recursor:
    pkg.installed


pdns-recursor-config:
    file.managed:
        - name: /etc/powerdns/recursor.d/saltshaker.yml
        - source: salt://powerdns/recursor.jinja.yml
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
            provide_dns64: {{pillar.get('powerdns', {}).get('provide_dns64', False)}}


pdns-recursor-dnssec-config:
    file.managed:
        - name: /etc/powerdns/recursor.d/dnssec.yml
        - source: salt://powerdns/dnssec.yml
        - user: root
        - group: root
        - mode: '0644'


pnds-recursor-override-resolv.conf:
    file.managed:
        - name: /etc/resolv.conf
        - contents: |
            nameserver 169.254.1.1
            nameserver ::1
        - mode: '0644'
        - user: root
        - group: root
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync

{% if salt['file.file_exists']('/etc/dhcp/dhclient.conf') %}
pdns-dhclient-enforce-nameservers:
    file.append:
        - name: /etc/dhcp/dhclient.conf
        - text: |
            supersede domain-name-servers 169.254.1.1;
            supersede dhcp6.name-servers ::1;
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync
{% elif salt['file.file_exists']('/etc/dhcpcd.conf') %}
pdns-dhcpcd-enforce-nameservers:
    file.append:
        - name: /etc/dhcpcd.conf
        - text: |
            static domain_name_servers=169.254.1.1, ::1
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync
{% endif %}


pdns-recursor-service:
    service.running:
        - name: pdns-recursor
        - sig: /usr/sbin/pdns_recursor
        - enable: True
        - init_delay: 3
        #- order: 10  # see ORDER.md
        - watch:
            - file: pdns-recursor-config
            - file: pdns-recursor-dnssec-config
        - require:
            - pkg: pdns-recursor
            - cmd: consul-sync
        - require_in:
            - cmd: powerdns-sync


pdns-consul-cache-wipe:
    cmd.run:
        - name: /usr/bin/rec_control wipe-cache service.consul$
        - watch:
            - service: consul-service-reload
        - require_in:
            - cmd: powerdns-sync
