
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
    # 'default' should be interpreted as a reference to the default certificates in ssl.sls
    pinned-ca-cert: default
    ssl: postgresql


# vim: syntax=yaml
