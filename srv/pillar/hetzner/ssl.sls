{% from 'shared/ssl.sls' import localca_location %}


ssl:
    sources:
        default:
            cert: ssl:maincert:cert
            chain: ssl:maincert:combined
            key: ssl:maincert:key
            full: ssl:maincert:combined-key


    environment-rootca-cert: {{salt['file.join'](localca_location, 'live-ca.crt')}}


    install-perenv-ca-certs:
        - salt://basics/crypto/apps/casserver-ca.crt
        - salt://basics/crypto/live/live-ca.crt


# vim: syntax=yaml
