enable-ipv4-nat:
    nftables.append:
        - table: nat
        - chain: postrouting
        - family: ip4
        - in-interface: {{pillar["ifassign"]["internal"]}}
        - out-interface: {{pillar["ifassign"]["external"]}}
        - jump: masquerade
        - order: 4
        - save: True
        - require:
            - pkg: nftables
