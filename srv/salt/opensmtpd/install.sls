
include:
    - basics.noexim


{% set ssl_filenames = pillar.get('ssl', {}).get('filenames', {}) %}
{% set ssl_sources = pillar.get('ssl', {}).get('sources', {}) %}
{% set smtp_receiver_ssl = pillar['smtp']['receiver'].get('ssl', pillar['smtp']['receiver'].get('sslcert', 'default')) %}
{% set smtp_relay_ssl = pillar['smtp']['relay'].get('ssl', pillar['smtp']['relay'].get('sslcert', 'default')) %}
{% set smtp_internal_relay_ssl = pillar['smtp']['internal-relay'].get(
                                    'ssl', pillar['smtp']['internal-relay'].get('sslcert', 'default')
                                ) %}
{% set smtp_receiver_sslcert = ssl_filenames[smtp_receiver_ssl]['chain'] if smtp_receiver_ssl in ssl_filenames
                              else pillar['smtp']['receiver'].get('sslcert', smtp_receiver_ssl) %}
{% set smtp_receiver_sslkey = ssl_filenames[smtp_receiver_ssl]['key'] if smtp_receiver_ssl in ssl_filenames
                             else pillar['smtp']['receiver'].get('sslkey', smtp_receiver_ssl) %}
{% set smtp_relay_sslcert = ssl_filenames[smtp_relay_ssl]['chain'] if smtp_relay_ssl in ssl_filenames
                           else pillar['smtp']['relay'].get('sslcert', smtp_relay_ssl) %}
{% set smtp_relay_sslkey = ssl_filenames[smtp_relay_ssl]['key'] if smtp_relay_ssl in ssl_filenames
                          else pillar['smtp']['relay'].get('sslkey', smtp_relay_ssl) %}
{% set smtp_internal_relay_sslcert = ssl_filenames[smtp_internal_relay_ssl]['chain']
                                     if smtp_internal_relay_ssl in ssl_filenames
                                     else pillar['smtp']['internal-relay'].get('sslcert', smtp_internal_relay_ssl) %}
{% set smtp_internal_relay_sslkey = ssl_filenames[smtp_internal_relay_ssl]['key']
                                    if smtp_internal_relay_ssl in ssl_filenames
                                    else pillar['smtp']['internal-relay'].get('sslkey', smtp_internal_relay_ssl) %}
{% set smtp_ssl_refs = [] %}
{% for ssl_ref in [smtp_receiver_ssl, smtp_relay_ssl, smtp_internal_relay_ssl] %}
    {% if ssl_ref in ssl_filenames and ssl_ref not in smtp_ssl_refs %}
        {% set x = smtp_ssl_refs.append(ssl_ref) %}
    {% endif %}
{% endfor %}


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
            - opensmtpd-filter-denyrelay
            - opensmtpd-filter-dnsbl
            - opensmtpd-filter-fail2banlog
            - opensmtpd-filter-greylistd
        - fromrepo: mn-release
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
        - mode: '0640'
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
            relay_hostname: {{pillar['smtp-outgoing']['hostname']}}
            internal_relay_hostname: {{pillar['smartstack-services']['smtp']['smartstack-hostname']}}
            receiver_ips: ["{{opensmtpd_ips['ipv4']['receiver']}}", "{{opensmtpd_ips['ipv6']['receiver']}}"]
            relay_ips: ["{{opensmtpd_ips['ipv4']['relay']}}", "{{opensmtpd_ips['ipv6']['relay']}}"]
            internal_relay_ips: ["{{opensmtpd_ips['ipv4']['internal_relay']}}", "{{opensmtpd_ips['ipv6']['internal_relay']}}"]
            receiver_certfile: >
                {{smtp_receiver_sslcert}}
            receiver_keyfile: >
                {{smtp_receiver_sslkey}}
            relay_certfile: >
                {{smtp_relay_sslcert}}
            relay_keyfile: >
                {{smtp_relay_sslkey}}
            internal_relay_certificate: >
                {{smtp_internal_relay_sslcert}}
            internal_relay_keyfile: >
                {{smtp_internal_relay_sslkey}}
            {% if pillar['smtp'].get('relay-via', {}).get('url', False) %}
            relay_via_url: {{pillar['smtp']['relay-via']['url']}}
            {% endif %}
            {% if pillar['smtp'].get('relay-via', {}).get('auth', False) %}
            relay_via_auth: {{pillar['smtp']['relay-via']['auth']}}
            {% endif %}
            enable_transactional_relay: {{pillar['smtp'].get('enable-transactional-relay', False)}}
            {% if pillar['smtp'].get('enable-transactional-relay', False) %}
                {% if pillar['smtp'].get('transactional-relay-via', {}).get('url', False) %}
            txrelay_via_url: {{pillar['smtp']['transactional-relay-via']['url']}}
                {% endif %}
                {% if pillar['smtp'].get('transactional-relay-via', {}).get('auth', False) %}
            txrelay_via_auth: {{pillar['smtp']['transactional-relay-via']['auth']}}
                {% endif %}
            {% endif %}
        - require:
            - pkg: opensmtpd
            - file: opensmtpd-authserver-config
{% for ssl_ref in smtp_ssl_refs %}
    {% set ssl_id = ssl_ref|replace('.', '-')|replace('_', '-')|replace(':', '-')|replace('/', '-') %}
    {% for material in ['chain', 'key'] %}
        {% if ssl_sources.get(ssl_ref, {}).get(material) and salt['pillar.fetch'](ssl_sources[ssl_ref][material], None) %}
            - file: ssl-certificate-{{ssl_id}}-{{material}}
        {% endif %}
    {% endfor %}
{% endfor %}


opensmtpd-service:
    service.running:
        - name: opensmtpd
        - sig: smtpd
        - enable: True
        - require:
            - email-storage
        - watch:
            - file: opensmtpd-config
{% for ssl_ref in smtp_ssl_refs %}
    {% set ssl_id = ssl_ref|replace('.', '-')|replace('_', '-')|replace(':', '-')|replace('/', '-') %}
    {% for material in ['chain', 'key'] %}
        {% if ssl_sources.get(ssl_ref, {}).get(material) and salt['pillar.fetch'](ssl_sources[ssl_ref][material], None) %}
            - file: ssl-certificate-{{ssl_id}}-{{material}}
        {% endif %}
    {% endfor %}
{% endfor %}


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
            required_permission: {{pillar['smtp']['require-permission']}}
        - require:
            - pkg: opensmtpd


opensmtpd-filter-denyrelay-config:
    file.managed:
        - name: /etc/smtpd/denyrelay.conf
        - contents: |
            # This config limits mail users to either no email relay or relay only to whitelisted
            # recipients.
            #
            # Example config:
            #    norelay@example.com
            #    relayonlyto@example.com=other@example.com
            #    relayoptions@example.com=one@example.com
            #    relayoptions@example.com=two@example.com
        - create: True
        - replace: False
        - mode: '0640'
        - user: opensmtpd
        - group: opensmtpd
        - require:
            - pkg: opensmtpd-filters

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
        - destination: '{{opensmtpd_ips['ipv4'][svc]}}/32'
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
        - source: '{{salt['network.ip_addrs6'](salt['network.default_route']('inet6')[0]['interface'], False)[0]}}/64'
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
        - source: '{{salt['network.ip_addrs6'](salt['network.default_route']('inet6')[0]['interface'], False)[0]}}/64'
        - destination: '::/0'
        - dport: 465
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
{% endif %}
