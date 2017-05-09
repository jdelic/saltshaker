# Install the Xen hypervisor and libvirt so it can be managed by salt-virt / terraform.
# Obviously, the hypervisor will like be already installed when you run this state. Otherwise
# you'll have to reboot to activate it and some other states may fail.

xen-hypervisor:
    pkg.installed:
        - pkgs:
            - xen-hypervisor-4.8-amd64
            - xen-system-amd64
            - xen-tools
            - xen-utils-4.8
            - xen-utils-common
            - xenstore-utils
            - libxen-4.8
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
