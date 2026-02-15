{% from 'config.sls' import external_tld %}

ci:
    enabled: True
    hostname: ci.{{external_tld}}
    protocol: https
    garden-docker-registry: registry-1.docker.io
