{% from "config.sls" import external_tld %}

vaultwarden:
    enabled: True
    hostname: pwd.{{external_tld}}
