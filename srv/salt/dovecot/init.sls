
{% set conffiles = ['10-auth.conf', '10-ssl.conf', '10-master.conf', '10-mail.conf', '15-lda.conf',
                    '20-managesieve.conf', '90-sieve.conf'] %}
{% set ssl_filenames = pillar.get('ssl', {}).get('filenames', {}) %}
{% set ssl_sources = pillar.get('ssl', {}).get('sources', {}) %}
{% set imap_external_ssl = pillar['imap']['external'].get('ssl', pillar['imap']['external'].get('sslcert', 'default')) %}
{% set imap_internal_ssl = pillar['imap']['internal'].get('ssl', pillar['imap']['internal'].get('sslcert', 'default')) %}
{% set imap_external_sslcert = ssl_filenames[imap_external_ssl]['chain'] if imap_external_ssl in ssl_filenames
                              else pillar['imap']['external'].get('sslcert', imap_external_ssl) %}
{% set imap_external_sslkey = ssl_filenames[imap_external_ssl]['key'] if imap_external_ssl in ssl_filenames
                             else pillar['imap']['external'].get('sslkey', imap_external_ssl) %}
{% set imap_internal_sslcert = ssl_filenames[imap_internal_ssl]['chain'] if imap_internal_ssl in ssl_filenames
                              else pillar['imap']['internal'].get('sslcert', imap_internal_ssl) %}
{% set imap_internal_sslkey = ssl_filenames[imap_internal_ssl]['key'] if imap_internal_ssl in ssl_filenames
                             else pillar['imap']['internal'].get('sslkey', imap_internal_ssl) %}
{% set imap_ssl_refs = [] %}
{% for ssl_ref in [imap_external_ssl, imap_internal_ssl] %}
    {% if ssl_ref in ssl_filenames and ssl_ref not in imap_ssl_refs %}
        {% set x = imap_ssl_refs.append(ssl_ref) %}
    {% endif %}
{% endfor %}

# http://wiki2.dovecot.org/Plugins/Antispam
dovecot:
    pkg.installed:
        - pkgs:
            - dovecot-core
            - dovecot-flatcurve
            - dovecot-imapd
            - dovecot-pgsql
            - dovecot-sieve
            - dovecot-managesieved
    service:
        - running
        - enable: True
        - watch:
{% for ssl_ref in imap_ssl_refs %}
    {% set ssl_id = ssl_ref|replace('.', '-')|replace('_', '-')|replace(':', '-')|replace('/', '-') %}
    {% for material in ['chain', 'key'] %}
        {% if ssl_sources.get(ssl_ref, {}).get(material) and salt['pillar.fetch'](ssl_sources[ssl_ref][material], None) %}
            - file: ssl-certificate-{{ssl_id}}-{{material}}
        {% endif %}
    {% endfor %}
{% endfor %}
            - file: dovecot-sql-config
        - require:
            - file: sa-learn-pipe-script


dovecot-systemd-secure-override:
    file.managed:
        - name: /etc/systemd/system/dovecot.service.d/secure-mount.conf
        - source: salt://dovecot/systemd-override.jinja.conf
        - mode: 644
        - makedirs: True
        - template: jinja
        - watch_in:
            - service: dovecot
        - require:
            - file: email-storage


sa-learn-pipe-script:
    file.managed:
        - name: /usr/local/bin/sa-learn-pipe.sh
        - source: salt://dovecot/sa-learn-pipe.sh
        - user: dovecot
        - group: dovecot
        - mode: 755
        - require:
            - pkg: spamassassin
            - pkg: dovecot
            - file: email-storage


{% set dovecot_ips = {
    "internal":
        pillar.get('imap-incoming', {}).get(
                'override-internal', grains['ip4_interfaces'][pillar['ifassign']['internal']][
                    pillar['ifassign'].get('internal-ip-index', 0)|int()
                ]
            ),
    "ipv4":
        pillar.get('imap-incoming', {}).get(
                'override-ipv4', grains['ip4_interfaces'].get(pillar['ifassign']['external'])[
                    pillar['ifassign'].get('external-ip-index', 0)|int()
                ]
            ) if pillar.get('imap-incoming', {}).get('bind-ipv4', True) else "",
    "ipv6":
        pillar.get('imap-incoming', {}).get(
                'override-ipv6',
                salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                pillar['ifassign-ipv6'].get('external-ipv6-suffix', "1")
                    if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 else ""
            ) if pillar.get('imap-incoming', {}).get('bind-ipv6', True) else ""
} %}

{% for file in conffiles %}
dovecot-config-{{file}}:
    file.managed:
        - name: /etc/dovecot/conf.d/{{file}}
        - source: salt://dovecot/conf.d/{{file}}
        - mode: 644
        - template: jinja
        - context:
            sslcert: >
                {{imap_external_sslcert}}
            sslkey: >
                {{imap_external_sslkey}}
            internal_sslcert: >
                {{imap_internal_sslcert}}
            internal_sslkey: >
                {{imap_internal_sslkey}}
            internalip: {{dovecot_ips['internal']}}
            bindips: ["{{dovecot_ips['internal']}}", "{{dovecot_ips['ipv4']}}", "{{dovecot_ips['ipv6']}}"]
            bindport: 143
            ssl_bindport: 993
        - watch_in:
            - service: dovecot
        - require:
            - pkg: dovecot
            - file: {{pillar['ssl']['service-rootca-cert']}}
{% endfor %}


dovecot-sql-config:
    file.managed:
        - name: /etc/dovecot/conf.d/auth-sql.conf.ext
        - source: salt://dovecot/conf.d/auth-sql.conf.ext
        - template: jinja
        - context:
            dbname: {{pillar['authserver']['dbname']}}
            sslrootcert: {{pillar['ssl']['service-rootca-cert']}}
            dbuser: dovecot-authserver
            dbpassword: {{pillar['dynamicsecrets']['dovecot-authserver']}}
            required_permission: {{pillar['imap']['require-permission']}}
        - require:
            - pkg: dovecot
            - file: {{pillar['ssl']['service-rootca-cert']}}


dovecot-consul-servicedef:
    file.managed:
        - name: /etc/consul/services.d/imap.json
        - source: salt://dovecot/consul/imap.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{dovecot_ips['internal']}}
            port: 993
        - require:
            - file: consul-service-dir


dovecot-in993-recv-internal:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{dovecot_ips['internal']}}
        - dport: 993
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


# allow others to contact us on ports (imap, imaps, managesieve)
{% for port in ['143', '993', '4190'] %}
    {% if pillar['imap-incoming'].get('bind-ipv4', True) %}
dovecot-in{{port}}-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{dovecot_ips['ipv4']}}
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
    {% if pillar['imap-incoming'].get('bind-ipv6', True) %}
dovecot-in{{port}}-recv-ipv6:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip6
        - jump: accept
        - source: '::/0'
        - destination: '{{dovecot_ips['ipv6']}}/128'
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup
    {% endif %}
{% endfor %}

# vim: syntax=yaml
