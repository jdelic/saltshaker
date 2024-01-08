# uncomment this for network debugging logging

#log-input-drops:
#    nftables.append:
#        - table: filter
#        - chain: INPUT
#        - jump: LOG
#        - log-prefix: "netfilter INPUT dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables


#log-output-drops:
#    nftables.append:
#        - table: filter
#        - chain: OUTPUT
#        - jump: LOG
#        - log-prefix: "netfilter OUTPUT dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables


#log-forward-drops:
#    nftables.append:
#        - table: filter
#        - chain: FORWARD
#        - jump: LOG
#        - log-prefix: "netfilter FORWARD dropped: "
#        - order: last
#        - require:
#            - sls: basics.nftables

