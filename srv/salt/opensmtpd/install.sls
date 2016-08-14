
opensmtpd:
    pkg.installed:
        pkgs:
            - opensmtpd
            - opensmtpd-extras
        fromrepo: stretch-testing


plusdashfilter:
    pkg.installed:
        - name: opensmtpd-plusdashfilter
        - require:
            - pkgrepo: maurusnet-repo


procmail:
    pkg.installed
