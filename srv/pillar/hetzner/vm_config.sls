# importable variables for reuse
{% if salt.saltutil.runner('mine.get', tgt=opts.id, 'envdir') %}
    {% if salt.saltutil.runner('mine.get', tgt=opts.id, 'envdir').get("server_type", "cx22").endswith("2") %}
        {% set iface_internal = "enp7s0" %}
    {% else %}
        {% set iface_internal = 'ens10' %}
    {% endif %}
{% else %}
    # sometimes grains are apparently not available, e.g. during a Reactor run. Then we do our best to fail.
    {% set iface_internal = 'unknown' %}
{% endif %}
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


enable_byobu:
    jonas: True

# vim: syntax=yaml

