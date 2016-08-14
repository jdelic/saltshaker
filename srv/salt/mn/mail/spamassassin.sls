
spamassassin:
    pkg.installed:
        - pkgs:
            - spamassassin
            - spamc
    service.running:
        - sig: spamd
        - enable: True
        - require:
            - pkg: spamassassin


# vim: syntax=yaml
