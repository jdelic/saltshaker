
opensmtpd:
    pkg.installed:
        - pkgs:
            - opensmtpd
            - libmariadbclient18  # dependency of opensmtpd-extras
        - install_recommends: False


opensmtpd-extras:
    pkg.installed:
        - pkgs:
            - opensmtpd-extras
            - opensmtpd-filter-greylistd
        - fromrepo: mn-opensmtpd
        - require:
            - pkg: opensmtpd
            - pkg: greylistd


# opensmtpd doesn't call initgroups() for filters so we can't put filter-greylistd
# in the greylist group. Instead we just change greylistd to run as the opensmtpd user.
# This will not make us measurably more insecure, imho.
greylistd-initd-user:
    file.replace:
        - name: /etc/init.d/greylistd
        - pattern: ^user=greylist$
        - repl: user=opensmtpd
        - backup: False


greylistd-initd-group:
    file.replace:
        - name: /etc/init.d/greylistd
        - pattern: ^group=greylist$
        - repl: group=opensmtpd
        - backup: False


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
            - file: greylistd-initd-user
            - file: greylistd-initd-group
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
    "relay": pillar.get('smtp-outgoing', {}).get(
                 'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external-alt']][pillar['ifassign'].get(
                     'external-alt-ip-index', 0
                 )|int()]
             ),
    "receiver": pillar.get('smtp-incoming', {}).get(
                    'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                        'external-ip-index', 0
                    )|int()]
                ),
    "internal_relay": pillar.get('smtp-local-relay', {}).get(
                          'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                              'internal-ip-index', 0
                          )|int()]
                      ),
} %}
opensmtpd-config:
    file.managed:
        - name: /etc/smtpd.conf
        - source: salt://opensmtpd/smtpd.jinja.conf
        - template: jinja
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
            relay_hostname: {{pillar['smtp-outgoing']['hostname']}}
            internal_relay_hostname: {{pillar['smtp']['smartstack-hostname']}}
            receiver_ip: {{opensmtpd_ips['receiver']}}
            relay_ip: {{opensmtpd_ips['relay']}}
            internal_relay_ip: {{opensmtpd_ips['internal_relay']}}
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
                    {{pillar['ssl']['relay']['sslkey']}}
                {%- endif %}
            internal_relay_certificate: >
                {% if pillar['smtp']['internal-relay']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['internal-relay']['sslcert']}}
                {%- endif %}
            internal_relay_keyfile: >
                {% if pillar['smtp']['relay']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else -%}
                    {{pillar['ssl']['internal-relay']['sslkey']}}
                {%- endif %}
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
            relayip: {{opensmtpd_ips['internal_relay']}}
            relayport: 25
        - require:
            - file: consul-service-dir


{% for svc in ['receiver', 'relay', 'internal_relay'] %}
opensmtpd-{{svc}}-tcp-in25-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{opensmtpd_ips[svc]}}/32
        - dport: 25
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


opensmtpd-relay-tcp-in465-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{opensmtpd_ips['relay']}}/32
        - dport: 465
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


opensmtpd-receiver-tcp-in465-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{opensmtpd_ips['receiver']}}/32
        - dport: 465
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


opensmtpd-relay-out25-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - source: {{salt['network.interface_ip'](salt['network.default_route']('inet')[0]['interface'])}}/32
        - destination: 0/0
        - dport: 25
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables

opensmtpd-relay-out465-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - source: {{salt['network.interface_ip'](salt['network.default_route']('inet')[0]['interface'])}}/32
        - destination: 0/0
        - dport: 465
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
