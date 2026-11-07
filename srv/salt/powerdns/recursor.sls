
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
            {% if pillar.get('local-development-environment-dns', False) %}
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
              {{pillar['smartstack-services'][service]['smartstack-hostname'][:-(pillar['config']['domains']['local']|length|int + 1)]}} IN A 127.0.0.1
              {% endif %}{% endfor %}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: pdns-recursor-local-zone-config
            - file: pdns-recursor-zone-dir


# If we're in a development environment, install a list of local well-known hosts in /etc/hosts
# so we don't need a local DNS server.
{% if pillar.get('local-development-environment-dns', False) %}
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

            @           IN  A   192.168.123.163
            
            ; nameserver glue (pick an IP that makes sense for your environment)
            ns1         IN  A   127.0.0.1
            
            ; /etc/hosts mappings
            saltmaster  IN  A   192.168.123.88
            anytype     IN  A   192.168.123.163
            auth        IN  A   192.168.123.163
            cal         IN  A   192.168.123.163
            ci          IN  A   192.168.123.163
            mail        IN  A   192.168.123.163
            notes       IN  A   192.168.123.163
            registry    IN  A   192.168.123.163
            schedule    IN  A   192.168.123.163
            smtp        IN  A   192.168.123.164

            beads       IN  A   192.168.123.163
            mcp-mail    IN  A   192.168.123.163

            element     IN  A   192.168.123.163
            matrix      IN  A   192.168.123.163
            matrix-rtc  IN  A   192.168.123.163

        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: pdns-recursor-local-zone-config
            - file: pdns-recursor-zone-dir
{% endif %}


# Use Debian's resolvconf to manage /etc/resolv.conf and always put our local
# resolver first by writing it to resolv.conf.d/head. This way DHCP clients can't
# replace it when they renew their leases or come up during boot.
pdns-resolvconf:
    pkg.installed:
        - name: resolvconf
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync


pdns-resolvconf-head:
    file.managed:
        - name: /etc/resolvconf/resolv.conf.d/head
        - contents: |
            # Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
            #     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
            # local pdns-recursor (managed by Salt)
            nameserver 169.254.1.1
            nameserver ::1
        - makedirs: True
        - mode: '0644'
        - user: root
        - group: root
        - require:
            - pkg: pdns-resolvconf
        - require_in:
            - cmd: powerdns-sync


# resolvconf appends the nameservers from all records in /run/resolvconf/interface/ that match a pattern in
# interface-order. dhcpcd, dhclient and ifupdown (dns-nameservers from cloud-init) all register records there,
# which adds the upstream resolvers or duplicates of ours. Without any patterns no records are used, so
# resolv.conf only contains what's in head.
pdns-resolvconf-interface-order:
    file.managed:
        - name: /etc/resolvconf/interface-order
        - contents: |
            # Managed by Salt (powerdns.recursor).
            # Intentionally contains no patterns, so resolvconf ignores all interface records and
            # /etc/resolv.conf only contains the local pdns-recursor from resolv.conf.d/head.
        - mode: '0644'
        - user: root
        - group: root
        - require:
            - pkg: pdns-resolvconf
        - require_in:
            - cmd: powerdns-sync


pdns-resolvconf-update:
    cmd.run:
        - name: /usr/sbin/resolvconf -u
        - onchanges:
            - file: pdns-resolvconf-head
            - file: pdns-resolvconf-interface-order
        - require_in:
            - cmd: powerdns-sync


# the resolvconf package normally does this on install, but make sure we don't
# keep a static /etc/resolv.conf around from earlier versions of this state
pdns-resolvconf-symlink:
    file.symlink:
        - name: /etc/resolv.conf
        - target: ../run/resolvconf/resolv.conf
        - force: True
        - require:
            - cmd: pdns-resolvconf-update
        - require_in:
            - cmd: powerdns-sync

{% if salt['file.file_exists']('/etc/dhcp/dhclient.conf') and salt['cmd.retcode']('pgrep -x dhclient') == 0 %}
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
{% elif salt['file.file_exists']('/etc/dhcpcd.conf') and salt['cmd.retcode']('pgrep -x dhcpcd') == 0 %}
# dhcpcd must not handle DNS at all. resolvconf gets our nameservers from
# pdns-resolvconf-head. "nohook resolv.conf" is what dhcpcd.conf(5) recommends to
# stop dhcpcd from touching DNS settings, which also covers IPv6 RDNSS.
pdns-dhcpcd-ignore-nameservers:
    file.append:
        - name: /etc/dhcpcd.conf
        - text: |
            nooption domain_name_servers
            nohook resolv.conf
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync

# remove the static nameserver config from earlier versions of this state
pdns-dhcpcd-remove-static-nameservers:
    file.replace:
        - name: /etc/dhcpcd.conf
        - pattern: '^static domain_name_servers=.*\n'
        - repl: ''
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync

pdns-dhcpcd-remove-nameservers-option:
    file.replace:
        - name: /etc/dhcpcd.conf
        - pattern: '^option domain_name_servers,(.*)$'
        - repl: 'option \1'
        - require:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync

pdns-dhcpcd-update:
    cmd.run:
        - name: dhcpcd -n
        # Only signal a dhcpcd running in manager mode. Without a manager "dhcpcd -n"
        # starts a new one, which then also grabs interfaces that are managed by
        # per-interface dhcpcd instances (hc-utils, ifupdown). Per-interface instances
        # pick up the new config when they are restarted.
        - onlyif: 'pgrep -f "^dhcpcd: \[manager\]"'
        - require:
            - file: pdns-dhcpcd-ignore-nameservers
            - file: pdns-dhcpcd-remove-static-nameservers
            - file: pdns-dhcpcd-remove-nameservers-option
        - require_in:
            - cmd: powerdns-sync
        - watch:
            - file: pdns-dhcpcd-ignore-nameservers
            - file: pdns-dhcpcd-remove-static-nameservers
            - file: pdns-dhcpcd-remove-nameservers-option
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
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                rec_control ping && host consul.service.consul && break;
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
        - onchanges:
            - service: pdns-recursor-service
        - require_in:
            - cmd: powerdns-sync


pdns-consul-cache-wipe:
    cmd.run:
        - name: /usr/bin/rec_control wipe-cache service.consul$; sleep 5
        - watch:
            - service: consul-service-reload
        - require_in:
            - cmd: powerdns-sync
