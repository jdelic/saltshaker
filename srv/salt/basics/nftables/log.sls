# uncomment this for network debugging logging

#log-input-drops:
#    nftables.append:
#        - table: filter
#        - chain: INPUT
#        - jump: log
#        - log-prefix: "netfilter INPUT dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables.setup


#log-output-drops:
#    nftables.append:
#        - table: filter
#        - chain: OUTPUT
#        - jump: log
#        - log-prefix: "netfilter OUTPUT dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables.setup


#log-forward-drops:
#    nftables.append:
#        - table: filter
#        - chain: FORWARD
#        - jump: log
#        - log-prefix: "netfilter FORWARD dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables.setup

