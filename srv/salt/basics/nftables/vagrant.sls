#
# vagrant-specific network config
#
# On vagrant VMs the first network interface is always the unrouted local network. Specifically for VirtualBox its a
# "NAT-injection" (not real NAT) device. Vagrant creates a socket forward for SSH services on that device. For libvirt
# it's a separate bridge on the host system.
#
# Since this should be only used in test environments, we just plain allow all traffic on that device.
#

{% if pillar["ifassign"].get("nat", False) %}
vagrant-eth0-recv:
    nftables.insert:
        - position: 1
        - table: filter
        - family: inet
        - chain: INPUT
        - jump: accept
        - in-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables


vagrant-eth0-send:
    nftables.insert:
        - position: 1
        - table: filter
        - family: inet
        - chain: OUTPUT
        - jump: accept
        - out-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables
{% endif %}
