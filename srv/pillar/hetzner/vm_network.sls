# importable variables for reuse
{% set iface_internal = 'ens10' %}
{% set iface_external = 'eth0' %}
{% set iface_external2 = 'eth1' %}

ifassign:
    internal: {{iface_internal}}
    external: {{iface_external}}
    external-alt: {{iface_external2}}

mine_functions:
    internal_ip:
        - mine_function: network.interface_ip
        - {{iface_internal}}
    external_ip:
        - mine_function: network.interface_ip
        - {{iface_external}}
    external_alt_ip:
        - mine_function: network.interface_ip
        - {{iface_external2}}


# vim: syntax=yaml

