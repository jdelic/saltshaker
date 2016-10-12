
opensmtpd:
    pkg.installed:
        - pkgs:
            - opensmtpd
            - opensmtpd-extras
        - fromrepo: stretch


{% if pillar['smtp']['receiver']['sslcert'] != 'default' %}
opensmtpd-receiver-sslcert:
    file.managed:
        - name: {{pillar['smtp']['receiver']['sslcert']}}
        - contents_pillar: {{pillar['smtp']['receiver']['sslcert-content']}}
        - mode: 440
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


opensmtpd-receiver-sslkey:
    file.managed:
        - name: {{pillar['smtp']['receiver']['sslkey']}}
        - contents_pillar: {{pillar['smtp']['receiver']['sslkey-content']}}
        - mode: 400
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
        - mode: 440
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


opensmtpd-relay-sslkey:
    file.managed:
        - name: {{pillar['smtp']['relay']['sslkey']}}
        - contents_pillar: {{pillar['smtp']['relay']['sslkey-content']}}
        - mode: 400
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
{% endif %}

opensmtpd-config:
    file.managed:
        - name: /etc/smtpd.conf
        - source: salt://opensmtpd/smtpd.jinja.conf
        - template: jinja
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
            relay_hostname: {{pillar['smtp-outgoing']['hostname']}}
            receiver_ip: {{pillar.get('smtp-incoming', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
            relay_ip: {{pillar.get('smtp-outgoing', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['external-alt']][pillar['ifassign'].get('external-alt-ip-index', 0)|int()])}}
            receiver_certfile: >
                {% if pillar['smtp']['receiver']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['receiver']['sslcert']}}
                {%- endif %}
            receiver_keyfile: >
                {% if pillar['smtp']['receiver']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['default-cert-key']}}
                {%- else -%}
                    {{pillar['smtp']['receiver']['sslkey']}}
                {%- endif %}
            relay_certfile: >
                {% if pillar['smtp']['relay']['sslcert'] == 'default' -%}
                    {{pillar['ssl']['default-cert-combined']}}
                {%- else -%}
                    {{pillar['smtp']['relay']['sslcert']}}
                {%- endif %}
            relay_keyfile: >
                {% if pillar['smtp']['relay']['sslkey'] == 'default' -%}
                    {{pillar['ssl']['default-cert-key']}}
                {%- else -%}
                    {{pillar['ssl']['relay']['sslkey']}}
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


#opensmtpd-service:
#    service.running:
#        - name: opensmtpd
#        - sig: smtpd
#        - enable: True
#        - require:
#            - file: opensmtpd-config
#            - email-storage


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
            dbpass: {{pillar['dynamicpasswords']['opensmtpd-authserver']}}
        - require:
            - pkg: opensmtpd


procmail:
    pkg.installed:
        - install_recommends: False
        # this would be a gratuitous requirement if procmail didn't pull in mail-transport-agent
        # which means exim is installed if opensmtpd fails to install
        - require:
            - pkg: opensmtpd


{% set spool = [
    ('/var/spool/smtpd', ('root', 'root', '0755')),
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
        - require:
            - pkg: opensmtpd
        #- require_in:
        #    - service: opensmtpd-service
{% endfor %}
# TODO: add iptables states
