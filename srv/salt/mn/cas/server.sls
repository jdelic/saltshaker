
# these states set up and configure the mailsystem CAS server
# and PAM for sogo.nu support

#authserver:
#    pkg.installed:
#        - name: maurusnet-authserver
#        - fromrepo: maurusnet
#        - require:
#            - file: authserver-config


authserver-config:
    file.directory:
        - name: /etc/appconfig/authserver
        - mode: '0755'
        - makedirs: True
        - require:
            - file: appconfig


{% set config = {
    "VAULT_CA": "/usr/share/ca-certificates/local/maurusnet-rootca.crt",
    "BINDIP": pillar.get('authserver', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()]),
    "BINDPORT": pillar.get('authserver', {}).get('bind-port', 8999),
    "DATABASE_NAME": pillar['authserver']['dbname'],
    "DATABASE_PARENTROLE": pillar['authserver']['dbuser'],
} %}


{% for envvar, value in config.items() %}
authserver-config-{{loop.index}}:
    file.managed:
        - name: /etc/appconfig/authserver/env/{{envvar}}
        - contents: {{value}}
        - require:
            - file: maurusnet-ca-root-certificate
            - file: authserver-config
{% endfor %}

# vim: syntax=yaml

