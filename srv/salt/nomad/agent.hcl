
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

    {% if pillar.get('nomad', {}).get('bridge-cidr', False) %}
        bridge_network_subnet = "{{pillar['nomad']['bridge-cidr']}}"
    {% endif %}
    {% if pillar.get('nomad', {}).get('bridge-cidr-ipv6', False) %}
        bridge_network_subnet_ipv6 = "{{pillar['nomad']['bridge-cidr-ipv6']}}"
    {% endif %}

    # this allows access to the cluster's root CA on every host (for .local services, for example)
    host_volume "host-ca-bundle" {
        path      = "/etc/ssl/certs/ca-certificates.crt"
        read_only = true
    }

    cni_path = "/usr/local/lib/nomad/"
    cni_config_dir = "/etc/nomad/cni/"
}

consul {
    address = "127.0.0.1:8500"
    token = "{{consul_acl_token}}"
}
