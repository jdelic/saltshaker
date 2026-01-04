#
# BASICS: nftables is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# WHY ORDER?
# This establishes static ordering here so that other states can insert their nftables rules using "order: 3 (or 4)"
# before nftables.init sets the default policies to DROP. Otherwise, the salt-minion will fail its first connection
# attempt to salt-master and wait for a full connection interval (usually 30 minutes) before trying again. So when
# bootstrapping a new installation this prevents a race condition. It also makes sure that certain netfilter rules
# which should go to the top of the list, actually go to the top of the list.
#
# As of Salt 3007.10, the nftables states are still broken in their detection of already existing rules. So we
# flush all baseconfig chains first before readding our own rules. This creates a short time window where the
# firewall is wide open.
#
# After that all other nftables states should establish order by requiring this sls, i.e.:
# ...
#    - require:
#        - sls: basics.nftables.setup
#

include:
    - basics.nftables.setup

nftables:
    pkg.installed:
        - order: 2


netfilter-persistent:
    pkg.installed:
        - order: 2


nftables-temp-input-allow-ipv4:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip4
        - chain: input
        - order: 2
        - save: False
        - require:
            - pkg: nftables


nftables-temp-input-allow-ipv6:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip6
        - chain: input
        - order: 2
        - save: False
        - require:
            - pkg: nftables


nftables-temp-output-allow-ipv4:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip4
        - chain: output
        - order: 2
        - save: False
        - require:
            - pkg: nftables


nftables-temp-output-allow-ipv6:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip6
        - chain: output
        - order: 2
        - save: False
        - require:
            - pkg: nftables


nftables-temp-forward-allow-ipv4:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip4
        - chain: forward
        - order: 2
        - save: False
        - require:
            - pkg: nftables


nftables-temp-forward-allow-ipv6:
    nftables.set_policy:
        - policy: allow
        - table: filter
        - family: ip6
        - chain: forward
        - order: 2
        - save: True
        - require:
            - pkg: nftables


nftables-baseconfig-chain-ipv4-input-flush:
    nftables.flush:
        - table: filter
        - chain: input
        - family: ip4
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv4-input
            - nftables: nftables-temp-input-allow-ipv4


nftables-baseconfig-chain-ipv6-input-flush:
    nftables.flush:
        - table: filter
        - chain: input
        - family: ip6
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv6-input
            - nftables: nftables-temp-input-allow-ipv6


nftables-baseconfig-chain-ipv4-output-flush:
    nftables.flush:
        - table: filter
        - chain: output
        - family: ip4
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv4-output
            - nftables: nftables-temp-output-allow-ipv4


nftables-baseconfig-chain-ipv6-output-flush:
    nftables.flush:
        - table: filter
        - chain: output
        - family: ip6
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv6-output
            - nftables: nftables-temp-output-allow-ipv6


nftables-baseconfig-chain-ipv4-forward-flush:
    nftables.flush:
        - table: filter
        - chain: forward
        - family: ip4
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv4-forward
            - nftables: nftables-temp-forward-allow-ipv4


nftables-baseconfig-chain-ipv6-forward-flush:
    nftables.flush:
        - table: filter
        - chain: forward
        - family: ip6
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv6-forward
            - nftables: nftables-temp-forward-allow-ipv6


nftables-baseconfig-chain-inet-input-flush:
    nftables.flush:
        - table: filter
        - chain: input
        - family: inet
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-inet-input


nftables-baseconfig-chain-inet-output-flush:
    nftables.flush:
        - table: filter
        - chain: output
        - family: inet
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-inet-output


nftables-baseconfig-chain-inet-forward-flush:
    nftables.flush:
        - table: filter
        - chain: forward
        - family: inet
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-inet-forward


nftables-baseconfig-chain-ipv4-prerouting-flush:
    nftables.flush:
        - table: nat
        - chain: prerouting
        - family: ip4
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv4-prerouting


nftables-baseconfig-chain-ipv4-postrouting-flush:
    nftables.flush:
        - table: nat
        - chain: postrouting
        - family: ip4
        - order: 2
        - require:
            - nftables: nftables-baseconfig-chain-ipv4-postrouting


# always allow local connections
localhost-recv-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: input
        - jump: accept
        - if: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-recv-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: input
        - jump: accept
        - if: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-send-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: output
        - jump: accept
        - of: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


localhost-send-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: output
        - jump: accept
        - of: lo
        - order: 3
        - save: True
        - require:
            - pkg: nftables


icmp-recv-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: input
        - jump: accept
        - proto: icmp
        - icmp-type: >
            echo-reply,destination-unreachable,source-quench,redirect,echo-request,time-exceeded,parameter-problem,
            timestamp-request,timestamp-reply,info-request,info-reply,address-mask-request,address-mask-reply,
            router-advertisement,router-solicitation
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-send-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: output
        - jump: accept
        - proto: icmp
        - icmp-type: >
            echo-reply,destination-unreachable,source-quench,redirect,echo-request,time-exceeded,parameter-problem,
            timestamp-request,timestamp-reply,info-request,info-reply,address-mask-request,address-mask-reply,
            router-advertisement,router-solicitation
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-forward-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: forward
        - jump: accept
        - proto: icmp
        - icmp-type: >
            echo-reply,destination-unreachable,source-quench,redirect,echo-request,time-exceeded,parameter-problem,
            timestamp-request,timestamp-reply,info-request,info-reply,address-mask-request,address-mask-reply,
            router-advertisement,router-solicitation
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-recv-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: input
        - jump: accept
        - proto: icmp
        - icmpv6-type: >
            destination-unreachable,packet-too-big,time-exceeded,parameter-problem,echo-request,
            echo-reply,mld-listener-query,mld-listener-report,mld-listener-done,mld-listener-reduction,
            nd-router-solicit,nd-router-advert,nd-neighbor-solicit,nd-neighbor-advert,
            nd-redirect,router-renumbering,ind-neighbor-solicit,ind-neighbor-advert,mld2-listener-report
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-send-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: output
        - jump: accept
        - proto: icmp
        - icmpv6-type: >
              destination-unreachable,packet-too-big,time-exceeded,parameter-problem,echo-request,
              echo-reply,mld-listener-query,mld-listener-report,mld-listener-done,mld-listener-reduction,
              nd-router-solicit,nd-router-advert,nd-neighbor-solicit,nd-neighbor-advert,
              nd-redirect,router-renumbering,ind-neighbor-solicit,ind-neighbor-advert,mld2-listener-report
        - order: 4
        - save: True
        - require:
            - pkg: nftables


icmp-forward-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: forward
        - jump: accept
        - proto: icmp
        - icmpv6-type: >
              destination-unreachable,packet-too-big,time-exceeded,parameter-problem,echo-request,
              echo-reply,mld-listener-query,mld-listener-report,mld-listener-done,mld-listener-reduction,
              nd-router-solicit,nd-router-advert,nd-neighbor-solicit,nd-neighbor-advert,
              nd-redirect,router-renumbering,ind-neighbor-solicit,ind-neighbor-advert,mld2-listener-report
        - order: 4
        - save: True
        - require:
            - pkg: nftables


# prevent tcp packets without a connection
drop-confused-tcp-packets-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: input
        - jump: drop
        - proto: tcp
        - match: state
        - connstate: invalid
        - order: 5
        - save: True
        - require:
            - pkg: nftables


drop-confused-tcp-packets-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: input
        - jump: drop
        - proto: tcp
        - match: state
        - connstate: invalid
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-input-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: input
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-input-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: input
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-output-ipv4:
    nftables.append:
        - table: filter
        - family: ip4
        - chain: output
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-output-ipv6:
    nftables.append:
        - table: filter
        - family: ip6
        - chain: output
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-forward-ipv4:
    nftables.append:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - table: filter
        - family: ip4
        - chain: forward
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-allow-related-established-forward-ipv6:
    nftables.append:
        # insert this right at the top, since we don't have preceding appends on the forward chain
        - table: filter
        - family: ip6
        - chain: forward
        - jump: accept
        - match: state
        - connstate: established,related
        - order: 4
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv4:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: input
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-input-drop-ipv6:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip6
        - chain: input
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv4:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: output
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-output-drop-ipv6:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip6
        - chain: output
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv4:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip4
        - chain: forward
        - order: 5
        - save: True
        - require:
            - pkg: nftables


nftables-default-forward-drop-ipv6:
    nftables.set_policy:
        - policy: drop
        - table: filter
        - family: ip6
        - chain: forward
        - order: 5
        - save: True
        - require:
            - pkg: nftables


enable-ipv4-forwarding:
    sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 1
        - order: 4


enable-ipv4-nonlocalbind:
    sysctl.present:
        - name: net.ipv4.ip_nonlocal_bind
        - value: 1
        - order: 4


enable-ipv6-nonlocalbind:
    sysctl.present:
        - name: net.ipv6.ip_nonlocal_bind
        - value: 1
        - order: 4


# vim: syntax=yaml
