
apache2:
    pkg.installed


libapache2-mod-xsendfile:
    pkg.installed


libapache2-mod-authnz-external:
    pkg.installed


authclient:
    pkg.installed


authnz-external-config:
    file.managed:
        - name: /etc/apache2/mods-available/authnz_external.conf
        - source: salt://apache/modules/authnz_external.conf


authnz-external-enable:
    cmd.run:
        - name: /usr/sbin/a2enmod authnz_external
        - require:
            - file: authnz-external-config


/etc/apache2/sites/000-default.conf:
    file.absent


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

