{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

docker:
    registry:
        enabled: True
        hostname: registry.{{external_tld}}


# vim: syntax=yaml
