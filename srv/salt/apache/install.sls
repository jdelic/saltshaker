
apache2:
    pkg.installed


libapache2-mod-xsendfile:
    pkg.installed


/etc/apache2/sites/000-default.conf:
    file.absent


apache2-service:
    service.running:
        - name: apache2
        - enable: True
        - reload: True
        - watch:
            - file: /etc/apache2/sites-enabled*
        - require:
            - pkg: apache2


# -* vim: syntax=yaml

