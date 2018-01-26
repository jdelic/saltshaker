# these states set up and configure the mailsystem CAS server

dkimsigner:
    pkg.installed:
        - name: authserver
        - fromrepo: mn-nightly
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
    "POSTGRESQL_CA": pillar['ssl']['service-rootca-cert'] if
        pillar['postgresql'].get('pinned-ca-cert', 'default') == 'default'
        else pillar['postgresql']['pinned-ca-cert'],
    "DATABASE_URL": 'postgresql://%s:@postgresql.local:5432/%s'|format(pillar['dkimsigner']['dbuser'],
        pillar['authserver']['dbname']),
    "ALLOWED_HOSTS": "%s,%s"|format(pillar['authserver']['hostname'], pillar['authserver']['smartstack-hostname']),
    "APPLICATION_LOGLEVEL": "INFO",
} %}


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
