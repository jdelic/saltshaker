# Install the Xen hypervisor and libvirt so it can be managed by salt-virt / terraform.
# Obviously, the hypervisor will like be already installed when you run this state. Otherwise
# you'll have to reboot to activate it and some other states may fail.

xen-hypervisor:
    pkg.installed:
        - pkgs:
            - xen-hypervisor-4.11-amd64
            - xen-system-amd64
            - xen-tools
            - xen-utils-4.11
            - xen-utils-common
            - xenstore-utils
            - libxencall1
            - libxendevicemodel1
            - libxenevtchn1
            - libxenforeignmemory1
            - libxengnttab1
            - libxenmisc4.11
            - libxenstore3.0
            - libxentoolcore1
            - libxentoollog1
            - libyajl2
            - libxenstore3.0
            - ipxe-qemu
            - qemu-system
            - qemu-system-arm
            - qemu-system-common
            - qemu-system-mips
            - qemu-system-misc
            - qemu-system-ppc
            - qemu-system-sparc
            - qemu-system-x86


libvirt-xen:
    pkg.installed:
        - pkgs:
            - libvirt-clients
            - libvirt-daemon
            - libvirt-daemon-system
            - libvirt0


xendomains-config:
    file.managed:
        - name: /etc/default/xendomains
        - source: salt://xen/xendomains
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: xen-hypervisor


xen-bridge-interfaces:
    file.managed:
        - name: /etc/network/interfaces.d/xenbridges
        - contents: |
            # This file is generated by Salt
            auto {{pillar['ifassign']['internal']}}

            iface {{pillar['ifassign']['internal']}} inet manual
                pre-up ip link add {{pillar['ifassign']['internal']}} type bridge
                pre-up ip link add {{pillar['ifassign']['real-internal']}} type dummy
                pre-up ip link set {{pillar['ifassign']['real-internal']}} up
                pre-up ip link set {{pillar['ifassign']['internal']}} up
                up ip link set xbr0dummy0 master {{pillar['ifassign']['internal']}}
                up ip addr add 10.0.1.1/24 dev {{pillar['ifassign']['internal']}}
                down ip link set {{pillar['ifassign']['internal']}} down
                post-down ip link del {{pillar['ifassign']['internal']}} type bridge
                post-down ip link del {{pillar['ifassign']['real-internal']}} type dummy

            auto {{pillar['ifassign']['real-external']}} {{pillar['ifassign']['external']}}

            iface {{pillar['ifassign']['real-external']}} inet manual
                up ip link set enp2s0 up
                down ip link set enp2s0 down

            iface {{pillar['ifassign']['external']}} inet manual
                pre-up ip link add {{pillar['ifassign']['external']}} type bridge
                pre-up ip link set {{pillar['ifassign']['real-external']}} up
                pre-up ip link set {{pillar['ifassign']['external']}} up
                up ip link set dev {{pillar['ifassign']['real-external']}} master {{pillar['ifassign']['external']}}
                up ip addr add {{pillar['network']['routed-ip']}}/32 peer {{pillar['network']['gateway']}} broadcast {{pillar['network']['routed-ip']}} dev {{pillar['ifassign']['external']}}
            {% for additional_ip in pillar['network'].get('additional-ips', []) %}
                up ip route add {{additional_ip}}/32 dev {{pillar['ifassign']['external']}}
            {% endfor %}
                up ip route add default via {{pillar['network']['gateway']}} dev {{pillar['ifassign']['external']}}
                down ip link set {{pillar['ifassign']['external']}} down
                post-down ip link del {{pillar['ifassign']['external']}} type bridge


xen-forward-domUs:
    iptables.append:
        - table: filter
        - chain: FORWARD
        - jump: ACCEPT
        - source: 10.0.1.0/24
        - destination: 0/0
        - save: True
        - require:
            - sls: iptables


xen-nat-domUs:
    iptables.append:
        - table: nat
        - chain: POSTROUTING
        - jump: MASQUERADE
        - source: 10.0.1.0/24
        - destination: '! 10.0.1.0/24'
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
