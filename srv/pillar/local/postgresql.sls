{% from 'shared/ssl.sls' import certificate_location, secret_key_location %}

postgresql:
    version: 18
    bind-port: 5432
    start-cluster: True

    sslcert: {{salt['file.join'](certificate_location, 'postgresql.crt')}}
    sslkey: {{salt['file.join'](secret_key_location, 'postgresql.key')}}

    hbafile: pg_hba.conf
