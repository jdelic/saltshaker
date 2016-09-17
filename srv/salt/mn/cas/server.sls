
# these states set up and configure the mailsystem CAS server
# and PAM for sogo.nu support

authserver:
    pkg.installed:
        - name: maurusnet-authserver
        - fromrepo: maurusnet
        - require:
            - file: authserver-config


authserver-config:
    file.directory:
        - name: /etc/appconfig/authserver
        - mode: '0755'
        - makedirs: True
        - require_in:
            - casserver-config-1
        - require:
            - file: appconfig

authserver-config-1:
    file.managed:
        - name: /etc/appconfig/authserver/MANAGED_CONFIG
        - source: salt://mn/cas/config.tpl
        - template: jinja
        - context:
            ca: /usr/share/ca-certificates/local/maurusnet-rootca.crt
            bindip: 192.168.56.88
            bindport: 9999
        - require:
            - file: maurusnet-ca-root-certificate


# vim: syntax=yaml

