
datacenter = "{{datacenter}}"

client {
    enabled = true

    # pin the "network device fingerprinting" to the network device connected
    # to the internal network. This is necessary so nomad doesn't instruct
    # docker to just bind any container to eth0's first IP.
    #
    # TODO: fix this when nomad 0.6 comes out with better network management
    network_interface = "{{internal_interface}}"
}

consul {
    address = "127.0.0.1:8500"
    token = "{{consul_acl_token}}"
}
