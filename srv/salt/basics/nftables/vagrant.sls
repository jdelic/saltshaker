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
vagrant-eth0-recv-ipv4:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip4
        - chain: input
        - jump: accept
        - in-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables


vagrant-eth0-recv-ipv6:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip6
        - chain: input
        - jump: accept
        - in-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables


vagrant-eth0-send-ipv4:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip4
        - chain: output
        - jump: accept
        - out-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables


vagrant-eth0-send-ipv6:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip6
        - chain: output
        - jump: accept
        - out-interface: {{pillar["ifassign"]["nat"]}}
        - order: 3
        - save: True
        - require:
            - pkg: nftables
{% endif %}
