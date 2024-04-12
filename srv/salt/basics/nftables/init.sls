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


nftables-baseconfig-table-inet-filter:
    nftables.table_present:
        - name: filter
        - family: inet
        - order: 2


nftables-baseconfig-table-ipv4-filter:
    nftables.table_present:
        - name: filter
        - family: ip4
        - order: 2


nftables-baseconfig-table-ipv6-filter:
    nftables.table_present:
        - name: filter
        - family: ip6
        - order: 2


nftables-baseconfig-chain-inet-input:
    nftables.chain_present:
        - name: INPUT
        - table: filter
        - table_type: filter
        - family: inet
        - hook: input
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-inet-filter


nftables-baseconfig-chain-ipv4-input:
    nftables.chain_present:
        - name: INPUT
        - table: filter
        - table_type: filter
        - family: ip4
        - hook: input
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv4-filter


nftables-baseconfig-chain-ipv6-input:
    nftables.chain_present:
        - name: INPUT
        - table: filter
        - table_type: filter
        - family: ip6
        - hook: input
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv6-filter


nftables-baseconfig-chain-inet-output:
    nftables.chain_present:
        - name: OUTPUT
        - table: filter
        - table_type: filter
        - family: inet
        - hook: output
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-inet-filter


nftables-baseconfig-chain-ipv4-output:
    nftables.chain_present:
        - name: OUTPUT
        - table: filter
        - table_type: filter
        - family: ip4
        - hook: output
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv4-filter


nftables-baseconfig-chain-ipv6-output:
    nftables.chain_present:
        - name: OUTPUT
        - table: filter
        - table_type: filter
        - family: ip6
        - hook: output
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv6-filter


nftables-baseconfig-chain-ipv4-forward:
    nftables.chain_present:
        - name: FORWARD
        - table: filter
        - table_type: filter
        - family: ip4
        - hook: forward
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv4-filter


nftables-baseconfig-chain-ipv6-forward:
    nftables.chain_present:
        - name: FORWARD
        - table: filter
        - table_type: filter
        - family: ip6
        - hook: forward
        - priority: 0
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv6-filter


# always allow local connections
localhost-recv-ipv4:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip4
        - chain: INPUT
        - jump: accept
        - in-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-recv-ipv6:
    nftables.insert:
        - position: 1
        - table: filter
        - family: ip6
        - chain: INPUT
        - jump: accept
        - in-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-send-ipv4:
    nftables.append:
        - position: 1
        - table: filter
        - family: ip4
        - chain: OUTPUT
        - jump: accept
        - out-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-send-ipv6:
    nftables.append:
        - position: 1
        - table: filter
        - family: ip6
        - chain: OUTPUT
        - jump: accept
        - out-interface: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


# always allow ICMP pings
icmp-recv-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: INPUT
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables

icmp-recv-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: INPUT
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-send-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: OUTPUT
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables

icmp-send-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: OUTPUT
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-forward-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: FORWARD
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables

icmp-forward-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: FORWARD
        - jump: accept
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - destination: 0/0
        - order: 4
        - save: True
        - require:
            - pkg: nftables


# prevent tcp packets without a connection
drop-confused-tcp-packets-ipv4:
    nftables.insert:
        - position: 3
        - table: filter
        - family: ip4
        - chain: INPUT
        - jump: drop
        - proto: tcp
        - match: state
        - connstate: new
        - tcp-flags: '! FIN,SYN,RST,ACK SYN'
        - order: 5
        - save: True
        - require:
            - pkg: nftables

drop-confused-tcp-packets-ipv6:
    nftables.insert:
        - position: 3
        - table: filter
        - family: ip6
        - chain: INPUT
        - jump: drop
        - proto: tcp
        - match: state
        - connstate: new
        - tcp-flags: '! FIN,SYN,RST,ACK SYN'
        - order: 5
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-input-ipv4:
    nftables.insert:
        - position: 2
        - table: filter
        - family: ip4
        - chain: INPUT
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables

iptables-default-allow-related-established-input-ipv6:
    nftables.insert:
        - position: 2
        - table: filter
        - family: ip6
        - chain: INPUT
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-output-ipv4:
    nftables.insert:
        - position: 2
        - table: filter
        - family: ip4
        - chain: OUTPUT
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables

iptables-default-allow-related-established-output-ipv6:
    nftables.insert:
        - position: 2
        - table: filter
        - family: ip6
        - chain: OUTPUT
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


iptables-default-allow-related-established-forward-ipv4:
    nftables.insert:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - position: 1
        - table: filter
        - family: ip4
        - chain: FORWARD
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables

iptables-default-allow-related-established-forward-ipv6:
    nftables.insert:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - position: 1
        - table: filter
        - family: ip6
        - chain: FORWARD
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv4:
    iptables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: INPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv6:
    iptables.set_policy:
        - policy: drop
        - table: filter
        - family: ip6
        - chain: INPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv4:
    iptables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: OUTPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv6:
    iptables.set_policy:
        - policy: drop
        - table: filter
        - family: ip6
        - chain: OUTPUT
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv4:
    iptables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: FORWARD
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv6:
    iptables.set_policy:
        - policy: drop
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
