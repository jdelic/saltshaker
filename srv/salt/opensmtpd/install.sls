
opensmtpd:
    pkg.installed:
        - pkgs:
            - opensmtpd
            - opensmtpd-extras
        - fromrepo: stretch


plusdashfilter:
    pkg.installed:
        - name: opensmtpd-plusdashfilter
        - require:
            - pkgrepo: maurusnet-repo


procmail:
    pkg.installed:
        - install_recommends: False
        # this would be a gratuitous requirement if procmail didn't pull in mail-transport-agent
        # which means exim is installed if opensmtpd fails to install
        - require:
            - pkg: opensmtpd
