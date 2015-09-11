
pam_cas:
    file.managed:
        - name: /lib/x86_64-linux-gnu/security/pam_cas.so
        - source: salt://mn/cas/pam_cas/pam_cas.so
    pkg.installed:
        - skip_verify: True
        - sources: 
            - checkpassword-pam: https://bitbucket.org/jdelic/checkpassword-pam/downloads/checkpassword-pam_0.99-1_amd64.deb


/etc/pam_cas.conf:
    file.managed:
        - source: salt://mn/cas/pam_cas/pam_cas.conf


# vim: syntax=yaml

