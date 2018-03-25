# these states set up and configure the mailsystem CAS server

dkimsigner:
    pkg.installed:
        - name: authserver
        - require:
            - appconfig: dkimsigner-appconfig
    service.running:
        - name: dkimsigner
        - sig: dkimsigner
        - enable: True
        - require:
            - pkg: dkimsigner


dkimsigner-appconfig:
    appconfig.present:
        - name: dkimsigner


dkimsigner-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/50-dkimsigner.rsyslog.conf
        - source: salt://mn/cas/50-dkimsigner.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'


{% set config = {
    "VAULT_CA": pillar['ssl']['service-rootca-cert'] if pillar['vault'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['vault']['pinned-ca-cert'],
    "BINDIP": '127.0.0.1',
    "BINDPORT": pillar.get('dkimsigner', {}).get('bind-port', 10036),
    "RELAYIP": '127.0.0.1',
    "RELAYPORT": pillar.get('dkimsigner', {}).get('relay-port', 10035),
    "DATABASE_NAME": pillar['authserver']['dbname'],
    "DATABASE_PARENTROLE": pillar['dkimsigner']['dbuser'],
    "POSTGRESQL_CA": pillar['ssl']['service-rootca-cert'] if
        pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['postgresql']['pinned-ca-cert'],
    "ALLOWED_HOSTS": "%s,%s"|format(pillar['authserver']['hostname'], pillar['authserver']['smartstack-hostname']),
    "APPLICATION_LOGLEVEL": "INFO",
} %}
{% if pillar['dkimsigner'].get('use-vault', False) %}
    {% set x = config.__setitem__("VAULT_DATABASE_PATH", 'postgresql/creds/authserver_dkimsigner') %}
    {% if pillar['dkimsigner'].get('vault-authtype', 'approle') == 'approle' %}
        {% set x = config.__setitem__("VAULT_ROLEID", pillar['dynamicsecrets']['dkimsigner-role-id']) %}
dkimsigner-config-secretid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write -f -format=json \
                auth/approle/role/dkimsigner/secret-id |
                jq -r .data.secret_id > /etc/appconfig/dkimsigner/env/VAULT_SECRETID
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - VAULT_TOKEN: {{pillar['dynamicsecrets']['approle-auth-token']}}
        - unless: >-
            test -f /etc/appconfig/dkimsigner/env/VAULT_SECRETID &&
            cat /etc/appconfig/dkimsigner/env/VAULT_SECRETID | \
                vault write auth/approle/login role_id={{config['VAULT_ROLEID']}} secret_id=- &&
            test $? -eq 0
        - watch_in:
            - service: dkimsigner
    {% endif %}
{% else %}
    {% set x = config.__setitem__("DATABASE_URL", 'postgresql://%s:@postgresql.local:5432/%s'|format(pillar['dkimsigner']['dbuser'],
        pillar['authserver']['dbname'])) %}
{% endif %}


{% for envvar, value in config.items() %}
dkimsigner-config-{{loop.index}}:
    file.managed:
        - name: /etc/appconfig/dkimsigner/env/{{envvar}}
        - contents: {{value}}
        - require:
            - file: {{pillar['ssl']['service-rootca-cert']}}
            - appconfig: dkimsigner-appconfig
        - watch_in:
            - service: dkimsigner
{% endfor %}


# vim: syntax=yaml
