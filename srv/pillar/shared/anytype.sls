{% from "config.sls" import external_tld %}

anytype:
    hostname: anytype.{{external_tld}}

    # this IP must not be routed in your network
    bridge-ip: 192.168.57.1
    bridge-cidr: 192.168.57.0/24
    container-cidr: 192.168.57.0/25
