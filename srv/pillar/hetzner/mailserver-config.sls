{% from 'config.sls' import external_tld %}
# look at local.mailserver-config for a documented full-fledged example

smtp-incoming:
    hostname: mail.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True


smtp-outgoing:
    hostname: smtp.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: False


imap-incoming:
    hostname: mail.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True

# vim: syntax=yaml
