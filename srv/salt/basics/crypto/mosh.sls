mosh:
    pkg.installed:
        - name: mosh
        - install_recommends: False


mosh-in60000-60010-udp-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - proto: udp
        - dport: 60000-60010
        - save: True
        - require:
            - sls: basics.nftables.setup


mosh-out60000-60010-udp-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - destination: '0/0'
        - proto: udp
        - sport: 60000-60010
        - save: True
        - require:
            - sls: basics.nftables.setup


mosh-in60000-60010-udp-ipv6:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip6
        - jump: accept
        - source: '::/0'
        - proto: udp
        - dport: 60000-60010
        - save: True
        - require:
            - sls: basics.nftables.setup


mosh-out60000-60010-udp-ipv6:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip6
        - jump: accept
        - destination: '::/0'
        - proto: udp
        - sport: 60000-60010
        - save: True
        - require:
            - sls: basics.nftables.setup
