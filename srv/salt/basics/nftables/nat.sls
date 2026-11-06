enable-ipv4-nat:
    nftables.append:
        - table: saltshaker
        - chain: postrouting
        - family: ip4
        - if: {{pillar["ifassign"]["internal"]}}
        - of: {{pillar["ifassign"]["external"]}}
        - jump: masquerade
        - order: 4
        - require:
            - pkg: nftables


enable-internal-forward:
    nftables.append:
        - table: saltshaker
        - chain: forward
        - family: ip4
        - if: {{pillar["ifassign"]["internal"]}}
        - jump: accept
        - order: 4
        - require:
            - pkg: nftables