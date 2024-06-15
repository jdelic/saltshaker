# This file can be referenced by other states to ensure that all nftables tables
# and chains are created before any rules are applied.
#
# Don't reference basics.nftables itself as it will flush all rules introduce
# salt bug 62203 where connstate flags aren't matched correctly.
#

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


nftables-baseconfig-table-inet-filter:
    nftables.table_present:
        - name: filter
        - family: inet
        - order: 2


nftables-baseconfig-chain-ipv4-input:
    nftables.chain_present:
        - name: input
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
        - name: input
        - table: filter
        - table_type: filter
        - family: ip6
        - hook: input
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv6-filter


nftables-baseconfig-chain-ipv4-output:
    nftables.chain_present:
        - name: output
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
        - name: output
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
        - name: forward
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
        - name: forward
        - table: filter
        - table_type: filter
        - family: ip6
        - hook: forward
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-ipv6-filter


nftables-baseconfig-chain-inet-input:
    nftables.chain_present:
        - name: input
        - table: filter
        - table_type: filter
        - family: inet
        - hook: input
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-inet-filter


nftables-baseconfig-chain-inet-output:
    nftables.chain_present:
        - name: output
        - table: filter
        - table_type: filter
        - family: inet
        - hook: output
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-inet-filter


nftables-baseconfig-chain-inet-forward:
    nftables.chain_present:
        - name: forward
        - table: filter
        - table_type: filter
        - family: inet
        - hook: forward
        - priority: 0
        - order: 2
        - require:
              - nftables: nftables-baseconfig-table-inet-filter


