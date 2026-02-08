
include:
    - powerdns.sync
    - consul.sync


pdns-recursor:
    pkg.installed:
        - order: 9
        - require_in:
            - cmd: powerdns-pkg-installed-sync


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
        - require:
            - pkg: pdns-recursor


pdns-recursor-dnssec-config:
    file.managed:
        - name: /etc/powerdns/recursor.d/dnssec.yml
        - source: salt://powerdns/dnssec.yml
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: pdns-recursor


pdns-recursor-zone-dir:
    file.directory:
        - name: /etc/powerdns/zones
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - pkg: pdns-recursor


pdns-recursor-local-zone-config:
    file.managed:
        - name: /etc/powerdns/recursor.d/local-zones.yml
        - contents: |
            recursor:
                auth_zones:
            {% if pillar.get('resolve_wellknown_hosts', False) %}
                    - zone: {{pillar['config']['domains']['external']}}
                      file: /etc/powerdns/zones/{{pillar['config']['domains']['external']}}.zone
            {% endif %}
                    - zone: local
                      file: /etc/powerdns/zones/local.zone
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: pdns-recursor


pdns-recursor-local-zone:
    file.managed:
        - name: /etc/powerdns/zones/local.zone
        - contents: |
              $ORIGIN local.
              $TTL 60

              @   IN  SOA ns1.local. hostmaster.local. (
                      2026020801 ; serial
                      3600       ; refresh
                      600        ; retry
                      1209600    ; expire
                      60         ; minimum
              )
                  IN  NS  ns1.local.

              ns1         IN  A   127.0.0.1

              {% for service in pillar['smartstack-services'] %}{% if pillar['smartstack-services'][service].get('smartstack-hostname', False) %}
              {{pillar['smartstack-services'][service]['smartstack-hostname']|trim('.%s' % pillar['config']['domains']['local'])}} IN A 127.0.0.1
              {% endif %}{% endfor %}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: pdns-recursor-local-zone-config


# If we're in a development environment, install a list of local well-known hosts in /etc/hosts
# so we don't need a local DNS server.
{% if pillar.get('local-development-environment-dns', False) %}
    {% set ipprefix = salt['network.interface_ip'](pillar['ifassign']['external']).split(".")[0:3]|join(".") %}
# You shouldn't use this outside of a LOCAL VAGRANT NETWORK. This configuration
# saves you from setting up a DNS server by replicating it in all nodes' /etc/hosts files.
pdns-recursor-external-zone:
    file.managed:
        - name: /etc/powerdns/zones/{{pillar['config']['domains']['external']}}.zone
        - contents: |
            $ORIGIN {{pillar['config']['domains']['external']}}.
            $TTL 60
            
            @   IN  SOA ns1.{{pillar['config']['domains']['external']}}. hostmaster.{{pillar['config']['domains']['external']}}. (
            2026020801 ; serial
            3600       ; refresh
            600        ; retry
            1209600    ; expire
            60         ; minimum
            )
            IN  NS  ns1.{{pillar['config']['domains']['external']}}.
            
            ; nameserver glue (pick an IP that makes sense for your environment)
            ns1         IN  A   127.0.0.1
            
            ; /etc/hosts mappings
            saltmaster  IN  A   {{ipprefix}}.88
            auth        IN  A   {{ipprefix}}.163
            mail        IN  A   {{ipprefix}}.163
            calendar    IN  A   {{ipprefix}}.163
            ci          IN  A   {{ipprefix}}.163
            smtp        IN  A   {{ipprefix}}.164
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: pdns-recursor-local-zone-config
{% endif %}


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
            static domain_name_servers=169.254.1.1 ::1
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
            - file: /etc/powerdns/zones/*
            - file: /etc/powerdns/recursor.d/*
        - require:
            - pkg: pdns-recursor
            - cmd: consul-sync
        - require_in:
            - cmd: powerdns-sync


pdns-consul-cache-wipe:
    cmd.run:
        - name: /usr/bin/rec_control wipe-cache service.consul$; sleep 5
        - watch:
            - service: consul-service-reload
        - require_in:
            - cmd: powerdns-sync
