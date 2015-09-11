# uncomment this for network debugging logging

#log-input-drops:
#    iptables.append:
#        - table: filter
#        - chain: INPUT
#        - jump: LOG
#        - log-prefix: "netfilter INPUT dropped: "
#        - order: last
#        - require:
#            - sls: iptables


#log-output-drops:
#    iptables.append:
#        - table: filter
#        - chain: OUTPUT
#        - jump: LOG
#        - log-prefix: "netfilter OUTPUT dropped: "
#        - order: last
#        - require:
#            - sls: iptables


#log-forward-drops:
#    iptables.append:
#        - table: filter
#        - chain: FORWARD
#        - jump: LOG
#        - log-prefix: "netfilter FORWARD dropped: "
#        - order: last
#        - require:
#            - sls: iptables

