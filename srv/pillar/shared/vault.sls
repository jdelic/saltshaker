{% from 'config.sls' import external_tld %}

vault:
    hostname: vault.{{external_tld}}
    # "default" should be interpreted as "use the ssl:service-rootca-cert"
    pinned-ca-cert: default
