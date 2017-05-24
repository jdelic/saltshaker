{% from 'shared/ssl.sls' import localca_location %}


ssl:
    sources:
        default-cert: ssl:testmaincert:cert
        default-cert-combined: ssl:testmaincert:combined
        default-cert-key: ssl:testmaincert:key
        default-cert-full: ssl:testmaincert:combined-key


    environment-rootca-cert: {{salt['file.join'](localca_location, 'dev-ca.crt')}}


    install-perenv-ca-certs:
        - salt://crypto/apps/casserver-ca.crt
        - salt://crypto/dev/dev-ca.crt

# vim: syntax=yaml
