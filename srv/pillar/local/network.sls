# importable variables for reuse
{% set iface_internal = 'eth1' %}
{% set iface_external = 'eth2' %}
{% set iface_external2 = 'eth3' %}


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


# You shouldn't use this outside of a LOCAL VAGRANT NETWORK. This configuration
# saves you from setting up a DNS server by replicating it in all nodes' /etc/hosts files.
wellknown_hosts: |
    192.168.56.162   cic.maurusnet.test auth.maurusnet.test
    192.168.56.163   smtp.maurusnet.test

# vim: syntax=yaml
