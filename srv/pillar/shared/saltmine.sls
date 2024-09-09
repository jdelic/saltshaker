
# states which should be queried and kept in the salt mine

# network saltmine values were moved into network config where they get aliases.
# Since pillars are combined, you can add additional mine_functions here.

mine_functions:
    network_interfaces:
        - mine_function: network.interfaces
#    network.ip_addrs: []

# vim: syntax=yaml

