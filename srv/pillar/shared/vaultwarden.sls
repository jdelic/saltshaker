{% from "config.sls" import external_tld %}

vaultwarden:
    hostname: bitwarden.{{external_tld}}
