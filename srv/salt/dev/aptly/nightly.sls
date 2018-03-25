
aptly-nightly:
    pkgrepo.managed:
        - humanname: Aptly Debian Nightly Builds
        - name: {{pillar["repos"]["aptly-nightly"]}}
        - file: /etc/apt/sources.list.d/aptly_nightly.list
        - key_url: salt://dev/aptly/aptly_ED75B5A4483DA07C.pgp.key
        - require_in:
            - pkg: aptly-nightly
    pkg.installed:
        - name: aptly

# vim: syntax=yaml
