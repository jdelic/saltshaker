{% from "config.sls" import external_tld %}


authserver:
    hostname: auth.{{external_tld}}

# vim: syntax=yaml
