
pam_cas:
    file.managed:
        - name: /lib/x86_64-linux-gnu/security/pam_cas.so
        - source: salt://mn/cas/pam_cas/pam_cas.so
    pkg.installed:
        - skip_verify: True
        - sources:
            - checkpassword-pam: https://bitbucket.org/jdelic/checkpassword-pam/downloads/checkpassword-pam_0.99-1_amd64.deb


pam_cas-config:
    file.managed:
        - name: /etc/pam_cas.conf
        - source: salt://mn/cas/pam_cas/pam_cas.conf


# vim: syntax=yaml

