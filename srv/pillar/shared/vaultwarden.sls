{% from "config.sls" import external_tld %}

vaultwarden:
    hostname: pwd.{{external_tld}}
