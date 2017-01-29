# importable variables for reuse
{% set internal_domain = "internal" %}  # for the local network
{% set local_domain = "local" %}  # for localhost only

internal-domain: {{internal_domain}}
local-domain: {{local_domain}}


docker:
    # this IP must not be routed in your network
    bridge-ip: 192.168.55.1/24
    container-cidr: 192.168.55.0/25


# vim: syntax=yaml
