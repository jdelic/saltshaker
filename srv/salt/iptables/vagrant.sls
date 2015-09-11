#
# vagrant-specific network config
#
# On vagrant VMs eth0 is always the unrouted local network. Specifically for VirtualBox its a "NAT-injection"
# (not real NAT) device. Vagrant creates a socket forward for SSH services on that device.
#
# Since this should be only used in test environments, we just plain allow all traffic on that device.
#

vagrant-eth0-recv:
    iptables.insert:
        - position: 2
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: eth0
        - order: 1
        - save: True
        - require:
            - pkg: iptables


vagrant-eth0-send:
    iptables.append:
        - position: 1
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: eth0
        - order: 1
        - save: True
        - require:
            - pkg: iptables
