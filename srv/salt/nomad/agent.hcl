
datacenter = "{{datacenter}}"
enable_syslog = true

client {
    enabled = true

    # pin the "network device fingerprinting" to the network device connected
    # to the internal network. This is necessary so nomad doesn't instruct
    # docker to just bind any container to eth0's first IP.
    #
    network_interface = "{{internal_interface}}"
    preferred_address_family = "ipv4"

    cni_path = "opt/cni/bin"
    cni_config_dir = "/etc/nomad/cni/"
}

consul {
    address = "127.0.0.1:8500"
    token = "{{consul_acl_token}}"
}
