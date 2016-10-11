
# these states set up and configure the mailsystem CAS server
# and PAM for sogo.nu support

#authserver:
#    pkg.installed:
#        - name: maurusnet-authserver
#        - fromrepo: maurusnet
#        - require:
#            - file: authserver-config


authserver-appconfig:
    appconfig.present:
        - name: authserver


{% set config = {
    "VAULT_CA": "/usr/share/ca-certificates/local/maurusnet-rootca.crt",
    "BINDIP": pillar.get('authserver', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()]),
    "BINDPORT": pillar.get('authserver', {}).get('bind-port', 8999),
    "DATABASE_NAME": pillar['authserver']['dbname'],
    "DATABASE_PARENTROLE": pillar['authserver']['dbuser'],
    "SPAPI_DBUSERS": pillar['authserver']['stored-procedure-api-users'],
} %}


{% for envvar, value in config.items() %}
authserver-config-{{loop.index}}:
    file.managed:
        - name: /etc/appconfig/authserver/env/{{envvar}}
        - contents: {{value}}
        - require:
            - file: {{pillar['ssl']['service-rootca-cert']}}
            - appconfig: authserver-appconfig
{% endfor %}


authserver-tcp-in{{pillar.get('authserver', {}).get('bind-port', 8999)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar.get('authserver', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('authserver', {}).get('bind-port', 8999)}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables

# vim: syntax=yaml
