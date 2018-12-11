
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
{% if pillar['imap']['sslcert'] != 'default' %}
            - file: dovecot-ssl-cert
            - file: dovecot-ssl-key
{% endif %}
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


dovecot-ssl-key:
    file.managed:
        - name: {{pillar['imap']['sslkey']}}
        - contents_pillar: {{pillar['imap']['sslkey-contents']}}
        - mode: 400
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
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
            bindip: {{pillar['imap'].get(
                    'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                        'external-ip-index', 0
                    )|int()]
                )}}
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


# allow others to contact us on ports (imap, imaps, managesieve)
{% for port in ['143', '993', '4190'] %}
dovecot-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar['imap'].get(
            'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                'external-ip-index', 0
            )|int()]
        )}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


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

# vim: syntax=yaml
