{% from "config.sls" import external_tld %}

standardnotes:
    hostname: stdnotesapi.{{external_tld}}
    webapp-hostname: notes.{{external_tld}}
    default-sync-server: https://stdnotesapi.{{external_tld}}
    cookie-domain: {{external_tld}}
    cookie-same-site: None
    cookie-secure: true
    cookie-partitioned: false

    # this IP must not be routed in your network
    bridge-ip: 192.168.56.1
    bridge-cidr: 192.168.56.0/24
    container-cidr: 192.168.56.0/25
