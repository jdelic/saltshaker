# importable variables for reuse
# https://devops.stackexchange.com/questions/1279/securely-grab-minion-id-in-pillar-top-file-template
{% if salt.saltutil.runner('mine.get', tgt=opts.id, fun='envdir') %}
    {% if salt.saltutil.runner('mine.get', tgt=opts.id, fun='envdir').get("server_type", "cx22").endswith("2") %}
        {% set iface_internal = "enp7s0" %}
    {% else %}
        {% set iface_internal = 'ens10' %}
    {% endif %}
{% else %}
    # sometimes grains are apparently not available. Then we do our best to fail.
    {% set iface_internal = 'run saltutil.refresh_pillar and mine.update' %}
{% endif %}
{% set iface_external = 'eth0' %}
{% set iface_external2 = 'eth0' %}


ifassign:
    internal: {{iface_internal}}
    internal-ip-index: 0
    external: {{iface_external}}
    external-ip-index: 0
    external-alt: {{iface_external2}}
    external-alt-ip-index: 1


ifassign-ipv6:
    #internal: {{iface_internal}}
    #internal-ip-suffix: 1
    external: {{iface_external}}
    external-ip-suffix: 1
    external-alt: {{iface_external2}}
    external-alt-ip-suffix: 2


mine_functions:
    internal_ip:
        - mine_function: network.interface_ip
        - {{iface_internal}}


# vim: syntax=yaml
