{% from "config.sls" import external_tld %}

vaultwarden:
    enabled: True
    hostname: bitwarden.{{external_tld}}
