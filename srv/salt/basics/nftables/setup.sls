# This file can be referenced by other states to ensure that all nftables tables
# and chains are created before any rules are applied.
#
# Don't reference basics.nftables itself as it will flush all rules introduce
# salt bug 62203 where connstate flags aren't matched correctly.
#
# All of our rules live in the "saltshaker" tables (one per family, holding both the
# filter and the nat chains). We don't use the "filter" and "nat" tables, because
# iptables-nft (used by Nomad/CNI and others) owns those and refuses to work on them
# once they contain rules it can't parse.
#

include:
    - basics.nftables.persist


nftables-baseconfig-table-ipv4:
    nftables.table_present:
        - name: saltshaker
        - family: ip4
        - order: 2


nftables-baseconfig-table-ipv6:
    nftables.table_present:
        - name: saltshaker
        - family: ip6
        - order: 2


nftables-baseconfig-chain-ipv4-input:
    nftables.chain_present:
        - name: input
        - table: saltshaker
        - table_type: filter
        - family: ip4
        - hook: input
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv4


nftables-baseconfig-chain-ipv6-input:
    nftables.chain_present:
        - name: input
        - table: saltshaker
        - table_type: filter
        - family: ip6
        - hook: input
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv6


nftables-baseconfig-chain-ipv4-output:
    nftables.chain_present:
        - name: output
        - table: saltshaker
        - table_type: filter
        - family: ip4
        - hook: output
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv4


nftables-baseconfig-chain-ipv6-output:
    nftables.chain_present:
        - name: output
        - table: saltshaker
        - table_type: filter
        - family: ip6
        - hook: output
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv6


nftables-baseconfig-chain-ipv4-forward:
    nftables.chain_present:
        - name: forward
        - table: saltshaker
        - table_type: filter
        - family: ip4
        - hook: forward
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv4


nftables-baseconfig-chain-ipv6-forward:
    nftables.chain_present:
        - name: forward
        - table: saltshaker
        - table_type: filter
        - family: ip6
        - hook: forward
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv6


nftables-baseconfig-chain-ipv4-postrouting:
    nftables.chain_present:
        - name: postrouting
        - table: saltshaker
        - table_type: nat
        - family: ip4
        - hook: postrouting
        - priority: 100
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv4


nftables-baseconfig-chain-ipv4-prerouting:
    nftables.chain_present:
        - name: prerouting
        - table: saltshaker
        - table_type: nat
        - family: ip4
        - hook: prerouting
        - priority: -150
        - order: 2
        - require:
            - nftables: nftables-baseconfig-table-ipv4
