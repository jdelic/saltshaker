
aptly:
    pkgrepo.managed:
        - humanname: Aptly Debian
        - name: {{pillar["repos"]["aptly"]}}
        - file: /etc/apt/sources.list.d/aptly.list
        - key_url: salt://dev/aptly/aptly_ED75B5A4483DA07C.pgp.key
        - require_in:
            - pkg: aptly
    pkg.installed:
        - name: aptly
    file.managed:
        - name: /etc/aptly/aptly.example.conf
        - source: salt://dev/aptly/aptly.example.jinja.conf
        - template: jinja
        - context:
            example: True
            rootdir: /srv/aptly/
        - makedirs: True
        - mode: '0644'


# vim: syntax=yaml
