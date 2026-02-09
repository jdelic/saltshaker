{% from 'config.sls' import external_tld %}

# importable variables for reuse
{% set iface_nat = 'eth0' %}
{% set iface_internal = 'eth1' %}
{% set iface_external = 'eth2' %}
{% set iface_external2 = 'eth3' %}


ifassign:
    nat: {{iface_nat}}
    internal: {{iface_internal}}
    external: {{iface_external}}
    external-alt: {{iface_external2}}


ifassign-ipv6:
    nat: {{iface_nat}}
    internal: {{iface_internal}}
    external: {{iface_external}}
    external-alt: {{iface_external2}}


mine_functions:
    internal_ip:
        - mine_function: network.interface_ip
        - {{iface_internal}}

# vim: syntax=yaml
