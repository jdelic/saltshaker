{% from 'shared/ssl.sls' import localca_location %}


ssl:
    sources:
        default:
            cert: ssl:testmaincert:cert
            chain: ssl:testmaincert:combined
            key: ssl:testmaincert:key
            full: ssl:testmaincert:combined-key


    environment-rootca-cert: {{salt['file.join'](localca_location, 'dev-ca.crt')}}


    install-perenv-ca-certs:
        - salt://basics/crypto/apps/casserver-ca.crt
        - salt://basics/crypto/dev/dev-ca.crt

# vim: syntax=yaml
