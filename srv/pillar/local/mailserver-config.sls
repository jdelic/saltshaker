{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

smtp-incoming:
    hostname: mail.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


smtp-outgoing:
    hostname: smtp.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


# CAREFUL: This is an open relay. Never use 'bind-ip' to bind this to an internet-facing IP!
# By default, this is bound to the internal network interface from the ifassign pillar
smtp-local-relay: # {}
    bind-ipv4: True
    bind-ipv6: False
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


imap-incoming:
    hostname: mail.{{external_tld}}

# vim: syntax=yaml

