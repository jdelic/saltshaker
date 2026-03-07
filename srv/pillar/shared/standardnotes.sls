{% from "config.sls" import external_tld %}

standardnotes:
    hostname: stdnotes.{{external_tld}}

    # this IP must not be routed in your network
    bridge-ip: 192.168.56.1
    bridge-cidr: 192.168.56.0/24
    container-cidr: 192.168.56.0/25

