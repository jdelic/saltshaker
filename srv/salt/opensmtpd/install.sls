
include:
    - basics.noexim


opensmtpd:
    pkg.installed:
        - pkgs:
            - opensmtpd
            - opensmtpd-table-postgres
        #- fromrepo: trixie-backports
        - install_recommends: False
        - require:
            - pkg: no-exim


opensmtpd-filters:
    pkg.installed:
        - pkgs:
            - opensmtpd-filter-greylistd
            - opensmtpd-filter-dnsbl
        - fromrepo: mn-nightly
        - install_recommends: False
        - require:
            - pkg: greylistd


# opensmtpd doesn't call initgroups() for filters so we can't put filter-greylistd
# in the greylist group. Instead we just change greylistd to run as the opensmtpd user.
# This will not make us measurably more insecure, imho.
greylistd-systemd-service-user-override:
    file.managed:
        - name: /etc/systemd/system/greylistd.service.d/override.conf
        - makedirs: True
        - user: root
        - group: root
        - mode: 0644
        - contents: |
            [Service]
            User=opensmtpd
            Group=opensmtpd


greylistd-systemd-socket-user-override:
    file.managed:
        - name: /etc/systemd/system/greylistd.socket.d/override.conf
        - makedirs: True
        - user: root
        - group: root
        - mode: 0644
        - contents: |
            [Socket]
            SocketUser=opensmtpd
            SocketGroup=opensmtpd


greylistd-systemd-override-reload:
    module.run:
        - name: service.systemctl_reload
        - onchanges:
            - file: greylistd-systemd-service-user-override
            - file: greylistd-systemd-socket-user-override


greylistd-modify-rundir:
    file.directory:
        - name: /run/greylistd
        - user: opensmtpd
        - group: opensmtpd
        - mode: '0755'
        - makedirs: True
        - recurse:
            - user
            - group


greylistd-modify-libdir:
    file.directory:
        - name: /var/lib/greylistd
        - user: opensmtpd
        - group: opensmtpd
        - recurse:
            - user
            - group


greylistd:
    pkg.installed:
        - name: greylistd
        - install_recommends: False
    service.running:
        - name: greylistd
        - sig: greylistd
        - enable: True
        - require:
            - pkg: greylistd
            - file: greylistd-systemd-service-user-override
            - file: greylistd-systemd-socket-user-override
            - module: greylistd-systemd-override-reload
            - file: greylistd-modify-rundir
            - file: greylistd-modify-libdir


amavisd:
    pkg.installed:
        - pkgs:
            - amavisd-new
            - clamav
        - install_recommends: False
    file.managed:
        - name: /etc/amavis/conf.d/51-salt
        - source: salt://opensmtpd/amavisd/51-salt
        - template: jinja
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
    service.running:
        - name: amavis
        - sig: amavisd-new
        - enable: True
        - watch:
            - file: /etc/amavis/conf.d*


{% if pillar['smtp']['receiver']['sslcert'] != 'default' %}
opensmtpd-receiver-sslcert:
    file.managed:
        - name: {{pillar['smtp']['receiver']['sslcert']}}
        - contents_pillar: {{pillar['smtp']['receiver']['sslcert-content']}}
        - mode: '0440'
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


opensmtpd-receiver-sslkey:
    file.managed:
        - name: {{pillar['smtp']['receiver']['sslkey']}}
        - contents_pillar: {{pillar['smtp']['receiver']['sslkey-content']}}
        - mode: '0400'
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
{% endif %}

{% if pillar['smtp']['relay']['sslcert'] != 'default' %}
opensmtpd-relay-sslcert:
    file.managed:
        - name: {{pillar['smtp']['relay']['sslcert']}}
        - contents_pillar: {{pillar['smtp']['relay']['sslcert-content']}}
        - mode: '0440'
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


opensmtpd-relay-sslkey:
    file.managed:
        - name: {{pillar['smtp']['relay']['sslkey']}}
        - contents_pillar: {{pillar['smtp']['relay']['sslkey-content']}}
        - mode: '0400'
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
{% endif %}


{% if pillar['smtp']['internal-relay']['sslcert'] != 'default' %}
opensmtpd-internal-relay-sslcert:
    file.managed:
        - name: {{pillar['smtp']['internal-relay']['sslcert']}}
        - contents_pillar: {{pillar['smtp']['internal-relay']['sslcert-content']}}
        - mode: '0440'
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


opensmtpd-internal-relay-sslkey:
    file.managed:
        - name: {{pillar['smtp']['internal-relay']['sslkey']}}
        - contents_pillar: {{pillar['smtp']['internal-relay']['sslkey-content']}}
        - mode: '0400'
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
{% endif %}


{% set opensmtpd_ips = {
    "ipv4": {
        "relay":
            pillar.get('smtp-outgoing', {}).get(
                'override-ipv4', grains['ip4_interfaces'].get(pillar['ifassign']['external-alt'])[
                    pillar['ifassign'].get('external-alt-ip-index', 0)|int()
                ]
            ) if pillar.get('smtp-outgoing', {}).get('bind-ipv4', True) else "",
        "receiver":
            pillar.get('smtp-incoming', {}).get(
                'override-ipv4', grains['ip4_interfaces'].get(pillar['ifassign']['external'])[
                    pillar['ifassign'].get('external-ip-index', 0)|int()
                ]
            ) if pillar.get('smtp-incoming', {}).get('bind-ipv4', True) else "",
        "internal_relay":
            pillar.get('smtp-local-relay', {}).get(
                'override-ipv4', grains['ip4_interfaces'].get(pillar['ifassign']['internal'])[
                    pillar['ifassign'].get('internal-ip-index', 0)|int()
                ]
            ) if pillar.get('smtp-local-relay', {}).get('bind-ipv4', True) else "",
    },
    "ipv6": {
        "relay":
            pillar.get('smtp-outgoing', {}).get(
                'override-ipv6',
                salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                pillar['ifassign-ipv6'].get('external-alt-ipv6-suffix', "2")
                    if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 else ""
            ) if pillar.get('smtp-outgoing', {}).get('bind-ipv6', False) else "",
        "receiver":
            pillar.get('smtp-incoming', {}).get(
                'override-ipv6',
                salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                pillar['ifassign-ipv6'].get('external-ipv6-suffix', "1")
                    if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 else ""
            ) if pillar.get('smtp-incoming', {}).get('bind-ipv6', False) else "",
        "internal_relay":
            pillar.get('smtp-local-relay', {}).get(
                'override-ipv6',
                salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                pillar['ifassign-ipv6'].get('internal-ipv6-suffix', "2")
                    if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 else ""
            ) if pillar.get('smtp-local-relay', {}).get('bind-ipv6', False) else "",
    }
} %}
opensmtpd-config:
    file.managed:
        - name: /etc/smtpd.conf
        - source: salt://opensmtpd/smtpd.jinja.conf
        - template: jinja
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
            relay_hostname: {{pillar['smtp-outgoing']['hostname']}}
            internal_relay_hostname: {{pillar['service']['smtp']['smartstack-hostname']}}
            receiver_ips: ["{{opensmtpd_ips['ipv4']['receiver']}}", "{{opensmtpd_ips['ipv6']['receiver']}}"]
            relay_ips: ["{{opensmtpd_ips['ipv4']['relay']}}", "{{opensmtpd_ips['ipv6']['relay']}}"]
            internal_relay_ips: ["{{opensmtpd_ips['ipv4']['internal_relay']}}", "{{opensmtpd_ips['ipv6']['internal_relay']}}"]
            receiver_certfile: >
                {% if pillar['smtp']['receiver']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['receiver']['sslcert']}}
                {%- endif %}
            receiver_keyfile: >
                {% if pillar['smtp']['receiver']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else -%}
                    {{pillar['smtp']['receiver']['sslkey']}}
                {%- endif %}
            relay_certfile: >
                {% if pillar['smtp']['relay']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['relay']['sslcert']}}
                {%- endif %}
            relay_keyfile: >
                {% if pillar['smtp']['relay']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else -%}
                    {{pillar['smtp']['relay']['sslkey']}}
                {%- endif %}
            internal_relay_certificate: >
                {% if pillar['smtp']['internal-relay']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['internal-relay']['sslcert']}}
                {%- endif %}
            internal_relay_keyfile: >
                {% if pillar['smtp']['internal-relay']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else -%}
                    {{pillar['smtp']['internal-relay']['sslkey']}}
                {%- endif %}
            {% if pillar['smtp'].get('relay-via', {}).get('url', False) %}
            relay_via_url: pillar['smtp']['relay-via']['url']
            {% endif %}
            {% if pillar['smtp'].get('relay-via', {}).get('auth', False) %}
            relay_via_auth: pillar['smtp']['relay-via']['auth']
            {% endif %}
        - require:
            - pkg: opensmtpd
            - file: opensmtpd-authserver-config
            {% if pillar['smtp']['receiver']['sslcert'] != 'default' %}
            - file: opensmtpd-receiver-sslcert
            - file: opensmtpd-receiver-sslkey
            {% endif %}
            {% if pillar['smtp']['relay']['sslcert'] != 'default' %}
            - file: opensmtpd-relay-sslcert
            - file: opensmtpd-relay-sslkey
            {% endif %}


opensmtpd-service:
    service.running:
        - name: opensmtpd
        - sig: smtpd
        - enable: True
        - require:
            - email-storage
        - watch:
            - file: opensmtpd-config
            {% if pillar['smtp']['receiver']['sslcert'] != 'default' %}
            - file: opensmtpd-receiver-sslcert
            - file: opensmtpd-receiver-sslkey
            {% endif %}
            {% if pillar['smtp']['relay']['sslcert'] != 'default' %}
            - file: opensmtpd-relay-sslcert
            - file: opensmtpd-relay-sslkey
            {% endif %}
            {% if pillar['smtp']['relay']['sslcert'] == 'default' or
                pillar['smtp']['receiver']['sslcert'] == 'default' %}
            - file: ssl-maincert-combined-certificate
            - file: ssl-maincert-key
            {% endif %}


opensmtpd-authserver-config:
    file.managed:
        - name: /etc/smtpd/postgresql.table.conf
        - source: salt://opensmtpd/postgresql.table.jinja.conf
        - template: jinja
        - makedirs: True
        - mode: '0600'
        - user: opensmtpd
        - group: opensmtpd
        - context:
            dbname: {{pillar['authserver']['dbname']}}
            # this is difficult to dedupe since pillars can't easily reference other pillars
            dbuser: opensmtpd-authserver
            dbpass: {{pillar['dynamicsecrets']['opensmtpd-authserver']}}
        - require:
            - pkg: opensmtpd


# ('/var/spool/smtpd/offline', ('root', 'root', '1777')),       <-- this is correct for opensmtpd 5.7.x
# ('/var/spool/smtpd/offline', ('root', 'opensmtpq', '0770')),  <-- this is correct for opensmtpd 5.9.x
{% set spool = [
    ('/var/spool/smtpd', ('root', 'root', '0711')),
    ('/var/spool/smtpd/corrupt',  ('opensmtpq', 'root', '0700')),
    ('/var/spool/smtpd/incoming', ('opensmtpq', 'root', '0700')),
    ('/var/spool/smtpd/offline', ('root', 'opensmtpq', '0770')),
    ('/var/spool/smtpd/purge', ('opensmtpq', 'root', '0700')),
    ('/var/spool/smtpd/queue', ('opensmtpq', 'root', '0700')),
    ('/var/spool/smtpd/temporary', ('opensmtpq', 'root', '0700')),
] %}

{% for dir in spool %}
mailspool-{{dir[0]}}:
    file.directory:
        - name: {{dir[0]}}
        - user: {{dir[1][0]}}
        - group: {{dir[1][1]}}
        - mode: {{dir[1][2]}}
        - makedirs: True
        - require:
            - pkg: opensmtpd
        - require_in:
            - service: opensmtpd-service
{% endfor %}


opensmtpd-servicedef-internal:
    file.managed:
        - name: /etc/consul/services.d/smtp.json
        - source: salt://opensmtpd/consul/smtp.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            relayip: {{opensmtpd_ips['ipv4']['internal_relay']}}
            relayport: 25
        - require:
            - file: consul-service-dir


{% for svc in ['receiver', 'relay', 'internal_relay'] %}
    {% if opensmtpd_ips['ipv4'][svc] %}
opensmtpd-{{svc}}-tcp-in25-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{opensmtpd_ips['ipv4'][svc]}}/32
        - dport: 25
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
    {% if opensmtpd_ips['ipv6'][svc] %}
opensmtpd-{{svc}}-tcp-in25-recv-ipv6:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip6
        - jump: accept
        - source: '::/0'
        - destination: '{{opensmtpd_ips['ipv6'][svc]}}'
        - dport: 25
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
{% endfor %}


{% for svc in ['receiver', 'relay', 'internal_relay'] %}
    {% if opensmtpd_ips['ipv4'][svc] %}
opensmtpd-{{svc}}-tcp-in465-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{opensmtpd_ips['ipv4'][svc]}}/32
        - dport: 465
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
    {% if opensmtpd_ips['ipv6'][svc] %}
opensmtpd-{{svc}}-tcp-in465-recv-ipv6:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip6
        - jump: accept
        - source: '::/0'
        - destination: '{{opensmtpd_ips['ipv6'][svc]}}'
        - dport: 465
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
{% endfor %}


{% if pillar["smtp-outgoing"].get("bind-ipv4", True) %}
opensmtpd-relay-out25-send-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - source: {{salt['network.interface_ip'](salt['network.default_route']('inet')[0]['interface'])}}/32
        - destination: 0/0
        - dport: 25
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


opensmtpd-relay-out465-send-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - source: {{salt['network.interface_ip'](salt['network.default_route']('inet')[0]['interface'])}}/32
        - destination: 0/0
        - dport: 465
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
{% endif %}

{% if salt['network.ip_addrs6'](salt['network.default_route']('inet6')[0]['interface'], False) %}
  {# if we have a default route, we can reach out to ipv6 mail servers #}
opensmtpd-relay-out25-send-ipv6:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip6
        - jump: accept
        - source: '{{salt['network.ip_addrs6'](salt['network.default_route']('inet6')[0]['interface'], False)[0]}}'
        - destination: '::/0'
        - dport: 25
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


opensmtpd-relay-out465-send-ipv6:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip6
        - jump: accept
        - source: '{{salt['network.ip_addrs6'](salt['network.default_route']('inet6')[0]['interface'], False)[0]}}'
        - destination: '::/0'
        - dport: 465
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
{% endif %}