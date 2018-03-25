# these states set up and configure the mailsystem CAS server

mailforwarder:
    pkg.installed:
        - name: authserver
        - require:
            - appconfig: mailforwarder-appconfig
    service.running:
        - name: mailforwarder
        - sig: mailforwarder
        - enable: True
        - require:
            - pkg: mailforwarder


mailforwarder-appconfig:
    appconfig.present:
        - name: mailforwarder


mailforwarder-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/50-mailforwarder.rsyslog.conf
        - source: salt://mn/cas/50-mailforwarder.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'


{% set config = {
    "VAULT_CA": pillar['ssl']['service-rootca-cert'] if pillar['vault'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['vault']['pinned-ca-cert'],
    "BINDIP": '127.0.0.1',
    "BINDPORT": pillar.get('mailforwarder', {}).get('bind-port', 10046),
    "DELIVERYIP": '127.0.0.1',
    "DELIVERYPORT": pillar.get('mailforwarder', {}).get('delivery-port', 10045),
    "RELAYIP": '127.0.0.1',
    "RELAYPORT": pillar.get('mailforwarder', {}).get('relay-port', 10045),
    "DATABASE_NAME": pillar['authserver']['dbname'],
    "DATABASE_PARENTROLE": pillar['mailforwarder']['dbuser'],
    "POSTGRESQL_CA": pillar['ssl']['service-rootca-cert'] if
        pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['postgresql']['pinned-ca-cert'],
    "ALLOWED_HOSTS": "%s,%s"|format(pillar['authserver']['hostname'], pillar['authserver']['smartstack-hostname']),
    "APPLICATION_LOGLEVEL": "INFO",
} %}
{% if pillar['mailforwarder'].get('use-vault', False) %}
    {% set x = config.__setitem__("VAULT_DATABASE_PATH", 'postgresql/creds/authserver_mailforwarder') %}
    {% if pillar['mailforwarder'].get('vault-authtype', 'approle') == 'approle' %}
        {% set x = config.__setitem__("VAULT_ROLEID", pillar['dynamicsecrets']['mailforwarder-role-id']) %}
mailforwarder-config-secretid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write -f -format=json \
                auth/approle/role/mailforwarder/secret-id |
                jq -r .data.secret_id > /etc/appconfig/mailforwarder/env/VAULT_SECRETID
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['approle-auth-token']}}
        - unless: >-
            test -f /etc/appconfig/mailforwarder/env/VAULT_SECRETID &&
            cat /etc/appconfig/mailforwarder/env/VAULT_SECRETID | \
                vault write auth/approle/login role_id={{config['VAULT_ROLEID']}} secret_id=- &&
            test $? -eq 0
        - watch_in:
            - service: mailforwarder
    {% endif %}
{% else %}
    {% set x = config.__setitem__("DATABASE_URL", 'postgresql://%s:@postgresql.local:5432/%s'|format(pillar['mailforwarder']['dbuser'],
        pillar['authserver']['dbname'])) %}
{% endif %}

{% for envvar, value in config.items() %}
mailforwarder-config-{{loop.index}}:
    file.managed:
        - name: /etc/appconfig/mailforwarder/env/{{envvar}}
        - contents: {{value}}
        - require:
            - file: {{pillar['ssl']['service-rootca-cert']}}
            - appconfig: mailforwarder-appconfig
        - watch_in:
            - service: mailforwarder
{% endfor %}


# vim: syntax=yaml
