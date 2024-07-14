
{% set conffiles = ['10-auth.conf', '10-ssl.conf', '10-master.conf', '10-mail.conf', '15-lda.conf',
                    '20-managesieve.conf', '90-plugin.conf', '90-sieve.conf', 'auth-sql.conf.ext'] %}

# http://wiki2.dovecot.org/Plugins/Antispam
dovecot:
    pkg.installed:
        - pkgs:
            - dovecot-core
            - dovecot-imapd
            - dovecot-antispam
            - dovecot-pgsql
            - dovecot-sieve
            - dovecot-managesieved
    service:
        - running
        - enable: True
        - watch:
{% if pillar['imap']['sslcert'] == 'default' %}
            - file: ssl-maincert-combined-certificate
            - file: ssl-maincert-key
{% endif %}
            - file: dovecot-sql-config
        - require:
            - file: sa-learn-pipe-script


{% if pillar['imap']['sslcert'] != 'default' %}
dovecot-ssl-cert:
    file.managed:
        - name: {{pillar['imap']['sslcert']}}
        - contents_pillar: {{pillar['imap']['sslcert-contents']}}
        - mode: 440
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location
        - require_in:
            - service: dovecot


dovecot-ssl-key:
    file.managed:
        - name: {{pillar['imap']['sslkey']}}
        - contents_pillar: {{pillar['imap']['sslkey-contents']}}
        - mode: 400
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
        - require_in:
            - service: dovecot
{% endif %}


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
    "ipv4":
        pillar.get('imap-incoming', {}).get(
                'override-ipv4', grains['ip4_interfaces'].get(pillar['ifassign']['external'])[
                    pillar['ifassign'].get('external-ip-index', 0)|int()
                ]
            ) if pillar.get('imap-incoming', {}).get('bind-ipv4', True) else "",
    "ipv6":
        pillar.get('imap-incoming', {}).get(
                'override-ipv6', grains['ip6_interfaces'].get(pillar['ifassign']['external'])[
                    pillar['ifassign'].get('external-ip-index', 0)|int()
                ]
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
                {%- if pillar['imap']['sslcert'] == 'default' %}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else %}
                    {{pillar['imap']['sslcert']}}
                {%- endif %}
            sslkey: >
                {%- if pillar['imap']['sslcert'] == 'default' %}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else %}
                    {{pillar['imap']['sslkey']}}
                {%- endif %}
            bindips: ["{{dovecot_ips['ipv4']}}", "{{dovecot_ips['ipv6']}}"]
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
        - name: /etc/dovecot/dovecot-sql.conf.ext
        - source: salt://dovecot/dovecot-sql.conf.jinja.ext
        - template: jinja
        - context:
            dbname: {{pillar['authserver']['dbname']}}
            sslrootcert: {{pillar['ssl']['service-rootca-cert']}}
            dbuser: dovecot-authserver
            dbpassword: {{pillar['dynamicsecrets']['dovecot-authserver']}}
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
            ip: {{pillar['imap'].get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                    'external-ip-index', 0
                )|int()]
            )}}
            port: 143
            sslip: {{pillar['imap'].get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                    'external-ip-index', 0
                )|int()]
            )}}
            sslport: 993
        - require:
            - file: consul-service-dir


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
        - destination: {{dovecot_ips['ipv6']}}
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
