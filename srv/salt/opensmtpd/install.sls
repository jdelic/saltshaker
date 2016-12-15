
opensmtpd:
    pkg.installed:
        - pkgs:
            - opensmtpd
            - libmariadbclient18  # dependency of opensmtpd-extras
        - install_recommends: False
        - fromrepo: stretch


opensmtpd-extras:
    pkg.installed:
        - pkgs:
            - opensmtpd-extras
            - opensmtpd-extras-experimental
            - opensmtpd-filter-greylistd
        - fromrepo: mn-experimental
        - require:
            - pkg: opensmtpd
            - pkg: greylistd


# opensmtpd doesn't call initgroups() for filters so we can't put filter-greylistd
# in the greylist group. Instead we just change greylistd to run in the right group.
greylistd-initd:
    file.replace:
        - name: /etc/init.d/greylistd
        - pattern: ^group=greylist$
        - repl: group=opensmtpd
        - backup: False


greylistd:
    pkg.installed:
        - name: greylistd
        - install_recommends: False
    service.running:
        - name: greylistd
        - enable: True
        - require:
            - pkg: greylistd
            - file: greylistd-initd


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


opensmtpd-config:
    file.managed:
        - name: /etc/smtpd.conf
        - source: salt://opensmtpd/smtpd.jinja.conf
        - template: jinja
        - context:
            receiver_hostname: {{pillar['smtp-incoming']['hostname']}}
            relay_hostname: {{pillar['smtp-outgoing']['hostname']}}
            internal_relay_hostname: {{pillar['smtp']['smartstack-hostname']}}
            receiver_ip: {{pillar.get('smtp-incoming', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                    'external-ip-index', 0
                )|int()]
            )}}
            relay_ip: {{pillar.get('smtp-outgoing', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external-alt']][pillar['ifassign'].get(
                    'external-alt-ip-index', 0
                )|int()]
            )}}
            internal_relay_ip: {{pillar.get('smtp-local-relay', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            )}}
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
            - file: opensmtpd-config
            - email-storage


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


procmail:
    pkg.installed:
        - install_recommends: False
        # this would be a gratuitous requirement if procmail didn't pull in mail-transport-agent
        # which means exim is installed if opensmtpd fails to install
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


opensmtpd-consul:
    file.managed:
        - name: /etc/consul/services.d/smtp.json
        - source: salt://opensmtpd/consul/smtp.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            relayip: {{pillar.get('smtp-local-relay', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            )}}
            relayport: 25
        - require:
            - file: consul-service-dir

# TODO: add iptables states
