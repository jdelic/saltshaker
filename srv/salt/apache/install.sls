
apache2:
    pkg.installed


libapache2-mod-xsendfile:
    pkg.installed


libapache2-mod-authnz-external:
    pkg.installed:
        - require:
            - pkg: apache2


authnz-external-enable:
    cmd.run:
        - name: /usr/sbin/a2enmod authnz_external
        - require:
            - pkg: libapache2-mod-authnz-external


/etc/apache2/sites/000-default.conf:
    file.absent


apache2-mods-symlink-directory:
    file.directory:
        - name: /etc/apache2/mods-enabled
        - user: root
        - group: root
        - mode: '0755'


apache2-sites-symlink-directory:
    file.directory:
        - name: /etc/apache2/sites-enabled
        - user: root
        - group: root
        - mode: '0755'


apache2-sites-config-directory:
    file.directory:
        - name: /etc/apache2/sites-available
        - user: root
        - group: root
        - mode: '0755'


# This uses the accumulator 'apache2-listen-ports' to get a list of all the ports that apache
# should listen on.
apache2-ports-config:
    file.managed:
        - name: /etc/apache2/ports.conf
        - source: salt://apache/ports.jinja.conf
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: apache2


apache2-service:
    service.running:
        - name: apache2
        - enable: True
        - require:
            - pkg: apache2
            - cmd: authnz-external-enable


apache2-service-reload:
    service.running:
        - name: apache2
        - enable: True
        - reload: True
        - watch:
            - file: /etc/apache2/sites-enabled*
            - file: /etc/apache2/sites-available*
            - file: /etc/apache2/mods-enabled*
            - file: apache2-ports-config
        - require:
            - service: apache2-service


# -* vim: syntax=yaml

