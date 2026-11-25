{% from "config.sls" import external_tld %}

greylistd-frontend:
    hostname: greylist.{{external_tld}}
    require-permission: greylist_admin
    # bind-ip: defaults to the internal interface's IP (ifassign:internal)
    # bind-port: 31090
