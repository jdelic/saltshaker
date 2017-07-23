# importable variables for reuse
{% set iface_internal = 'xenbr0' %}
{% set iface_external = 'xenbr1' %}

ifassign:
    internal: {{iface_internal}}
    real-internal: xbr0dummy0
    external: {{iface_external}}
    real-external: enp2s0


network:
    routed-ip: 144.76.72.112
    gateway: 144.76.72.97
    additional-ips:
        - 144.76.72.92
        - 144.76.72.94
        - 144.76.72.126


mine_functions:
    internal_ip:
        - mine_function: network.interface_ip
        - {{iface_internal}}
    external_ip:
        - mine_function: network.interface_ip
        - {{iface_external}}


enable_byobu:
    jonas: True

# vim: syntax=yaml
