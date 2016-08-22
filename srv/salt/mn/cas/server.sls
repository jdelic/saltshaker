
# these states set up and configure the mailsystem CAS server
# and PAM for sogo.nu support

casserver:
    pkg.installed:
        - name: maurusnet-casserver
        - fromrepo: maurusnet
        - require:
            - file: casserver-config


casserver-config:
    file.directory:
        - name: /etc/appconfig/casserver/envdir
        - mode: '0755'
        - makedirs: True
        - require_in:
            - casserver-config-1
            - casserver-config-2
        - require:
            - file: appconfig

casserver-config-1:
    file.managed:
        - name: /etc/appconfig/casserver/envdir/DATABASE_URL
        - contents: {{pillar['casserver']['database_url']}}

casserver-config-2:
    file.managed:
        - name: /etc/appconfig/casserver/envdir/SECRET_KEY
        - contents: {{pillar['dynamicpasswords']['casserver_django_secret_key']}}


# vim: syntax=yaml

