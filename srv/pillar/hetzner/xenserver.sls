# importable variables for reuse
{% set iface_internal = 'xbr0dummy0' %}
{% set iface_external = 'xenbr1' %}

ifassign:
    internal: {{iface_internal}}
    external: {{iface_external}}


network:
    routed-ip: 144.76.72.112
    gateway: 144.76.72.97


mine_functions:
    internal_ip:
        - mine_function: network.interface_ip
        - {{iface_internal}}
    external_ip:
        - mine_function: network.interface_ip
        - {{iface_external}}


# vim: syntax=yaml
