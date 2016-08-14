
spamassassin:
    pkg.installed:
        - pkgs:
            - spamassassin
            - spamc
        - install_recommends: False
    service.running:
        - sig: spamd
        - enable: True
        - require:
            - pkg: spamassassin


# vim: syntax=yaml
