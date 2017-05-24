
ssl:
    sources:
        default-cert: ssl:maincert:cert
        default-cert-combined: ssl:maincert:combined
        default-cert-key: ssl:maincert:key
        default-cert-full: ssl:maincert:combined-key


    environment-rootca-cert: {{salt['file.join'](localca_location, 'live-ca.crt')}}


    install-perenv-ca-certs:
        - salt://crypto/apps/casserver-ca.crt
        - salt://crypto/live/live-ca.crt


# vim: syntax=yaml
