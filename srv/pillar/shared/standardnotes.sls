{% from "config.sls" import external_tld %}

standardnotes:
    hostname: stdnotesapi.{{external_tld}}
    webapp-hostname: notes.{{external_tld}}
    default-sync-server: https://stdnotesapi.{{external_tld}}

    # this IP must not be routed in your network
    bridge-ip: 192.168.56.1
    bridge-cidr: 192.168.56.0/24
    container-cidr: 192.168.56.0/25
