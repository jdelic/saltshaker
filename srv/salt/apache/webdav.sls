apache2-webdav-config:
    file.managed:
        - name: /etc/apache2/sites-available/001-webdav.conf
        - source: salt://apache2/sites/webdav.jinja.conf
        - template: jinja
        - context:
            internal_ip: {{}}
            port: {{pillar['apache2']['webdav'].get('bind-port', 32443)}}
