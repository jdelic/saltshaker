{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

ci:
    hostname: ci.{{external_tld}}
    protocol: https
    garden-docker-registry: registry-1.docker.io
