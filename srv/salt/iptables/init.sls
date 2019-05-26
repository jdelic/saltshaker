#
# BASICS: iptables is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# WHY ORDER?
# This establishes static ordering here so that other states can insert their iptables rules using "order: 2 (or 3)"
# before iptables.init sets the default policies to DROP. Otherwise the salt-minion will fail its first connection
# attempt to salt-master and wait for a full connection interval (usually 30 minutes) before trying again. So when
# bootstrapping a new installation this prevents a race condition. It also makes sure that certain netfilter rules
# which should to to the top of the list, actually go to the top of the list.
#
# After that all other iptables states should establish order by requiring this sls, i.e.:
# ...
#    - require:
#        - sls: iptables
#

iptables:
    pkg.installed:
        - order: 1


iptables-persistent:
    pkg.installed:
        - order: 1


# always allow local connections
localhost-recv:
    iptables.insert:
        - position: 1
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: lo
        - order: 1
        - save: True
        - require:
            - pkg: iptables


localhost-send:
    iptables.append:
        - position: 1
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: lo
        - order: 1
        - save: True
        - require:
            - pkg: iptables


# always allow ICMP pings
icmp-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - order: 2
        - save: True
        - require:
            - pkg: iptables


icmp-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - destination: 0/0
        - order: 2
        - save: True
        - require:
            - pkg: iptables


icmp-forward:
    iptables.append:
        - table: filter
        - chain: FORWARD
        - jump: ACCEPT
        - proto: icmp
        - icmp-type: any
        - source: 0/0
        - destination: 0/0
        - order: 2
        - save: True
        - require:
            - pkg: iptables


# prevent tcp packets without a connection
drop-confused-tcp-packets:
    iptables.insert:
        - position: 3
        - table: filter
        - chain: INPUT
        - jump: DROP
        - proto: tcp
        - match: state
        - connstate: NEW
        - tcp-flags: '! FIN,SYN,RST,ACK SYN'
        - order: 3
        - save: True
        - require:
            - pkg: iptables


iptables-default-allow-related-established-input:
    iptables.insert:
        - position: 2
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 2  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: iptables


iptables-default-allow-related-established-output:
    iptables.insert:
        - position: 2
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 2  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: iptables


iptables-default-allow-related-established-forward:
    iptables.insert:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - position: 1
        - table: filter
        - chain: FORWARD
        - jump: ACCEPT
        - match: state
        - connstate: ESTABLISHED,RELATED
        - order: 2  # this is order "2" so it executes together with basics.sls
        - save: True
        - require:
            - pkg: iptables



iptables-default-input-drop:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - chain: INPUT
        - order: 3
        - save: True
        - require:
            - pkg: iptables


iptables-default-output-drop:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - chain: OUTPUT
        - order: 3
        - save: True
        - require:
            - pkg: iptables


iptables-default-forward-drop:
    iptables.set_policy:
        - policy: DROP
        - table: filter
        - chain: FORWARD
        - order: 3
        - save: True
        - require:
            - pkg: iptables


enable-ipv4-forwarding:
    sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 1


enable-ipv4-nonlocalbind:
    sysctl.present:
        - name: net.ipv4.ip_nonlocal_bind
        - value: 1


# vim: syntax=yaml

