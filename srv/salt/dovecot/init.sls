
{% set conffiles = ['10-auth.conf', '10-ssl.conf', '10-master.conf', '90-plugin.conf', 'auth-mnetcheckpwd.conf.ext'] %}

# http://wiki2.dovecot.org/Plugins/Antispam
dovecot:
    pkg.installed:
        - pkgs:
            - dovecot-core
            - dovecot-imapd
            - dovecot-antispam
    service:
        - running
        - enable: True
        - watch:
{% for file in conffiles %}
            - file: /etc/dovecot/conf.d/{{file}}
{% endfor %}
        - require:
{% for file in conffiles %}
            - file: /etc/dovecot/conf.d/{{file}}
{% endfor %}
            - file: dovecot-ssl-cert
            - file: dovecot-ssl-key
            - file: sa-learn-pipe-script


dovecot-ssl-cert:
    file.managed:
        - name: {{pillar['imap']['sslcert']}}
        - contents_pillar: ssl:maincert:combined
        - mode: 440
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


dovecot-ssl-key:
    file.managed:
        - name: {{pillar['imap']['sslkey']}}
        - contents_pillar: ssl:maincert:key
        - mode: 400
        - user: root
        - group: root
        - require:
            - file: ssl-key-location


sa-learn-pipe-script:
    file.managed:
        - name: /usr/local/bin/sa-learn-pipe.sh
        - source: salt://dovecot/sa-learn-pipe.sh
        - user: dovecot
        - group: dovecot
        - mode: 755
        - require:
            - pkg: spamassassin
            - file: email-storage


# only used if casserver is available
dovecot-pam:
    file.managed:
        - name: /etc/pam.d/dovecot
        - source: salt://mn/mail/dovecot.pam


{% for file in conffiles %}
dovecot-config-{{file}}:
    file.managed:
        - name: /etc/dovecot/conf.d/{{file}}
        - source: salt://dovecot/conf.d/{{file}}
        - mode: 644
        - template: jinja
        - require:
            - pkg: dovecot
{% endfor %}


{% for port in ['143', '993'] %}
# allow others to contact us on ports
dovecot-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar['imap'].get('ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
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
        - source: salt://dovecot/consul/imap.json
        - mode: '0644'
        - template: jinja
        - require:
            - file: consul-service-dir

# vim: syntax=yaml
