# importable variables for reuse
{% from 'config.sls' import internal_domain, local_domain %}

internal-domain: {{internal_domain}}
local-domain: {{local_domain}}


docker:
    # this IP must not be routed in your network
    bridge-ip: 192.168.55.1
    bridge-cidr: 192.168.55.1/24
    container-cidr: 192.168.55.0/25


# vim: syntax=yaml
