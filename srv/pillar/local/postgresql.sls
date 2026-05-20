{% from 'shared/ssl.sls' import combined_location, secret_key_location %}

ssl:
    filenames:
        postgresql:
            chain: {{salt['file.join'](combined_location, 'postgresql.crt')}}
            key: {{salt['file.join'](secret_key_location, 'postgresql.key')}}

    sources:
        postgresql:
            chain: ssl:postgresql:combined
            key: ssl:postgresql:key

postgresql:
    version: 18
    bind-port: 5432
    start-cluster: True

    ssl: postgresql

    hbafile: pg_hba.conf
