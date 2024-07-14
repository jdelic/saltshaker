{% from 'shared/ssl.sls' import localca_location %}


ssl:
    sources:
        default-cert: ssl:maincert:cert
        default-cert-combined: ssl:maincert:combined
        default-cert-key: ssl:maincert:key
        default-cert-full: ssl:maincert:combined-key


    environment-rootca-cert: {{salt['file.join'](localca_location, 'live-ca.crt')}}


    install-perenv-ca-certs:
        - salt://basics/crypto/apps/casserver-ca.crt
        - salt://basics/crypto/live/live-ca.crt


# vim: syntax=yaml
