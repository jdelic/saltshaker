# these states set up and configure the mailsystem CAS server

include:
    - mn.cas.sync


authserver:
    pkg.installed:
        - name: authserver
        #- fromrepo: mn-nightly  # install nightly version instead of release
        - require:
            - appconfig: authserver-appconfig
    service.running:
        - name: authserver
        - sig: authserver.wsgi
        - enable: True
        - init_delay: 3
        - require:
            - pkg: authserver
            - service: smartstack-internal
            - service: consul-template-service
            - file: authserver-servicedef-internal
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                if curl -s --fail http://authserver.local:8999/health/; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
        - onchanges:
            - service: authserver
        - require_in:
            - cmd: authserver-sync


authserver-appconfig:
    appconfig.present:
        - name: authserver


authserver-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/50-authserver.rsyslog.conf
        - source: salt://mn/cas/50-authserver.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'


{% set config = {
    "VAULT_CA": pillar['ssl']['service-rootca-cert'] if pillar['vault'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['vault']['pinned-ca-cert'],
    "BINDIP": pillar.get('authserver', {}).get(
        'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
            'internal-ip-index', 0
        )|int()]
    ),
    "BINDPORT": pillar.get('authserver', {}).get('bind-port', 8999),
    "DATABASE_NAME": pillar['authserver']['dbname'],
    "DATABASE_PARENTROLE": pillar['authserver']['dbuser'],
    "POSTGRESQL_CA": pillar['ssl']['service-rootca-cert'] if
        pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['postgresql']['pinned-ca-cert'],
    "ALLOWED_HOSTS": "%s,%s"|format(pillar['authserver']['hostname'], pillar['authserver']['smartstack-hostname']),
    "CORS_ORIGIN_REGEX_WHITELIST": "^https://(\w+\.)?(maurusnet\.test|maurus\.net)$",
    "USE_X_FORWARDED_HOST": "true",
    "APPLICATION_LOGLEVEL": "INFO",
} %}

{# because we don't have jinja2.ext.do, we have to use the following work-around to set dict items #}
{% if pillar['authserver'].get('use-vault', False) %}
    {% set x = config.__setitem__("VAULT_DATABASE_PATH", 'postgresql/creds/authserver_fullaccess') %}
    {% if pillar['authserver'].get('vault-authtype', 'approle') == 'approle' %}
        {% set x = config.__setitem__("VAULT_ROLEID", pillar['dynamicsecrets']['authserver-role-id']) %}
authserver-config-secretid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write -f -format=json \
                auth/approle/role/authserver/secret-id |
                jq -r .data.secret_id > /etc/appconfig/authserver/env/VAULT_SECRETID
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['approle-auth-token']}}
        - unless: >-
            test -f /etc/appconfig/authserver/env/VAULT_SECRETID &&
            cat /etc/appconfig/authserver/env/VAULT_SECRETID | \
                vault write auth/approle/login role_id={{config['VAULT_ROLEID']}} secret_id=- &&
            test $? -eq 0
        - watch_in:
            - service: authserver
        - require:
            - cmd: authserver-sync-vault
    {% endif %}
{% else %}
    {% set x = config.__setitem__("DATABASE_URL",
            'postgresql://%s:@postgresql.local:5432/%s'|format(pillar['authserver']['dbuser'],
                                                               pillar['authserver']['dbname'])
        ) %}
{% endif %}

{% for envvar, value in config.items() %}
authserver-config-{{loop.index}}:
    file.managed:
        - name: /etc/appconfig/authserver/env/{{envvar}}
        - contents: {{value}}
        - require:
            - file: {{pillar['ssl']['service-rootca-cert']}}
            - appconfig: authserver-appconfig
        - watch_in:
            - service: authserver
{% endfor %}


authserver-spapi-install:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py spapi --settings=authserver.settings install
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py spapi --settings=authserver.settings check --installed
        - require:
            - service: authserver


{% for spapi_user in pillar['authserver'].get('stored-procedure-api-users', []) %}
authserver-grant-spapi-access-{{spapi_user}}:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py spapi --settings=authserver.settings grant {{spapi_user}}
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py spapi --settings=authserver.settings check \
                    --grant={{spapi_user}}
        - require:
            - cmd: authserver-spapi-install
{% endfor %}


authserver-create-auth-domain:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings create \
                    --create-key jwt {{pillar['authserver'].get('sso-auth-domain', pillar['authserver']['hostname'])}}
        - unless: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings list \
                    --include-parent-domain {{pillar['authserver']['hostname']}}
        - require:
            - service: authserver


authserver-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/authserver-external.json
        - source: salt://mn/cas/consul/authserver.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: authserver
            routing: external
            protocol: {{pillar['authserver']['protocol']}}
            suffix: ext
            mode: http
            ip: {{config['BINDIP']}}
            port: {{config['BINDPORT']}}
            hostname: {{pillar['authserver']['hostname']}}
        - require:
            - file: consul-service-dir


authserver-servicedef-internal:
    file.managed:
        - name: /etc/consul/services.d/authserver-internal.json
        - source: salt://mn/cas/consul/authserver.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: authserver
            routing: internal
            suffix: int
            mode: http
            ip: {{config['BINDIP']}}
            port: {{config['BINDPORT']}}
        - require:
            - file: consul-service-dir


authserver-tcp-in{{pillar.get('authserver', {}).get('bind-port', 8999)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{config['BINDIP']}}/32
        - dport: {{config['BINDPORT']}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables

# vim: syntax=yaml
