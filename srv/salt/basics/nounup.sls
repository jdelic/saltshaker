# Kill unattended upgrades just in case

unattended-upgrades:
    service.dead:
        - enable: False
    pkg.purged:
        - require:
            - service: unattended-upgrades
