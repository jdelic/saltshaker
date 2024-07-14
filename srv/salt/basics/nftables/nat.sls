enable-ipv4-nat:
    nftables.append:
        - table: nat
        - chain: postrouting
        - family: ip4
        - if: {{pillar["ifassign"]["internal"]}}
        - of: {{pillar["ifassign"]["external"]}}
        - jump: masquerade
        - order: 4
        - save: True
        - require:
            - pkg: nftables


enable-internal-forward:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - if: {{pillar["ifassign"]["internal"]}}
        - jump: accept
        - order: 4
        - save: True
        - require:
            - pkg: nftables