#
# BASICS: nftables is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# WHY ORDER?
# This establishes static ordering here so that other states can insert their nftables rules using "order: 2 (or 3)"
# before nftables.init sets the default policies to DROP. Otherwise, the salt-minion will fail its first connection
# attempt to salt-master and wait for a full connection interval (usually 30 minutes) before trying again. So when
# bootstrapping a new installation this prevents a race condition. It also makes sure that certain netfilter rules
# which should go to the top of the list, actually go to the top of the list.
#
# After that all other nftables states should establish order by requiring this sls, i.e.:
# ...
#    - require:
#        - sls: basics.nftables
#

nftables:
    pkg.installed:
        - order: 2


netfilter-persistent:
    pkg.installed:
        - order: 2


# always allow local connections
localhost-recv:
    nftables.insert:
        - position: 1
        - table: filter
        - family: inet
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-send:
    nftables.append:
        - position: 1
        - table: filter
        - family: inet
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


# always allow ICMP pings
icmp-recv:
    nftables.append:
        - table: filter
        - family: inet
        - chain: INPUT
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-send:
    nftables.append:
        - table: filter
        - family: inet
        - chain: OUTPUT
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-forward:
    nftables.append:
        - table: filter
        - family: inet
        - chain: FORWARD
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


# prevent tcp packets without a connection
drop-confused-tcp-packets:
    nftables.insert:
        - position: 3
        - table: filter
        - family: inet
        - chain: INPUT
        - jump: DROP
        - proto: tcp
        - match: state
        - connstate: NEW
        - tcp-flags: '! FIN,SYN,RST,ACK SYN'
        - order: 5
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-input:
    nftables.insert:
        - position: 2
        - table: filter
        - family: inet
        - chain: INPUT
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 4  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-output:
    nftables.insert:
        - position: 2
        - table: filter
        - family: inet
        - chain: OUTPUT
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 4  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-forward:
    nftables.insert:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - position: 1
        - table: filter
        - family: inet
        - chain: FORWARD
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 4  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv4:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip4
        - chain: INPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv6:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip6
        - chain: INPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv4:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip4
        - chain: OUTPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv6:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip6
        - chain: OUTPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv4:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip4
        - chain: FORWARD
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv6:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - family: ip6
        - chain: FORWARD
        - order: 5
        - save: True
        - require:
            - pkg: nftables


enable-ipv4-forwarding:
    sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 1


enable-ipv4-nonlocalbind:
    sysctl.present:
        - name: net.ipv4.ip_nonlocal_bind
        - value: 1


enable-ipv6-nonlocalbind:
    sysctl.present:
        - name: net.ipv6.ip_nonlocal_bind
        - value: 1


# vim: syntax=yaml

