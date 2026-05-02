{% from 'config.sls' import external_tld %}
{% from 'shared/ssl.sls' import combined_location, secret_key_location %}

ssl:
    filenames:
        vault:
            chain: {{salt['file.join'](combined_location, 'vault.crt')}}
            key: {{salt['file.join'](secret_key_location, 'vault.key')}}

    sources:
        vault:
            chain: ssl:vault:combined
            key: ssl:vault:key

vault:
    hostname: vault.{{external_tld}}
    # "default" should be interpreted as "use the ssl:service-rootca-cert"
    pinned-ca-cert: default
    ssl: vault
