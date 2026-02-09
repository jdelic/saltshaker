{% from 'config.sls' import external_tld %}

service:
    docker-registry:
        enabled: True
        hostname: registry.{{external_tld}}


# vim: syntax=yaml
