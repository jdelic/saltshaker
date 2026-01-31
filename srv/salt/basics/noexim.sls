
no-exim:
    service.dead:
        - name: exim4
        - enable: False
    pkg.purged:
        - pkgs:
            - exim4-daemon-light
            - exim4-config
            - exim4-base
        - require:
            - service: exim4
