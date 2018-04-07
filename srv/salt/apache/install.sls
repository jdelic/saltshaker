
apache2:
    pkg.installed


libapache2-mod-xsendfile:
    pkg.installed


libapache2-mod-authnz-external:
    pkg.installed:
        - require:
            - pkg: apache2


authclient:
    pkg.installed


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


apache2-service:
    service.running:
        - name: apache2
        - enable: True
        - reload: True
        - watch:
            - file: /etc/apache2/sites-enabled*
            - file: /etc/apache2/mods-enabled*
        - require:
            - pkg: apache2


# -* vim: syntax=yaml

