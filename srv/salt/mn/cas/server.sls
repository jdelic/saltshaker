
# these states set up and configure the mailsystem CAS server
# and PAM for sogo.nu support

casserver:
    pkg.installed:
        - pkgs:
            - libmysqlclient18
            - libmysqlclient-dev
            - python-dev
            - libssl-dev
            - libevent-dev
            - libevent-openssl-2.0-5
        - require:
            - sls: compilers
            - sls: djb.daemontools
            - file: casserver-config
    file.symlink:
        - target: /srv/casserver
        - name: /etc/service/casserver


casserver-config: 
    file.directory:
        - name: /etc/mn-config/casserver/envdir
        - mode: '0755'
        - makedirs: True
        - require:
            - file: mn-config

casserver-config-1:
    file.managed:
        - name: /etc/mn-config/casserver/envdir/DATABASE_URL
        - contents: {{pillar['casserver']['database_url']}} 

casserver-config-2:
    file.managed:
        - name: /etc/mn-config/casserver/envdir/SECRET_KEY
        - contents: {{pillar['dynamicpasswords']['casserver_django_secret_key']}}
        

# vim: syntax=yaml

