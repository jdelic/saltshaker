{% from 'shared/ssl.sls' import certificate_location, secret_key_location %}

postgresql:
    version: 11
    bind-port: 5432
    start-cluster: True

    # 'default' should be interpreted as a reference to the default certificates in ssl.sls
    sslcert: {{salt['file.join'](certificate_location, 'postgresql.crt')}}
    sslkey: {{salt['file.join'](secret_key_location, 'postgresql.key')}}

    hbafile: pg_hba.conf


# vim: syntax=yaml
