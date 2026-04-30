{% from 'config.sls' import external_tld %}

smtp-incoming:
    hostname: mail.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True
    # override-ipv4: 123.123.123.123  # override interface bindings to bind to a specific IP
    # override-ipv6: 1234:1234::0


smtp-outgoing:
    hostname: smtp.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: True
    # override-ipv4: 123.123.123.123   # override interface bindings to bind to a specific IP
    # override-ipv6: 1234:1234::0

# CAREFUL: This is an open relay. Never use 'bind-ip' to bind this to an internet-facing IP!
# By default, this is bound to the internal network interface from the ifassign pillar
smtp-local-relay: # {}
    bind-ipv4: True
    bind-ipv6: False
    # override-ipv4: 123.123.123.123   # override interface bindings to bind to a specific IP
    # override-ipv6: 1234:1234::0


imap-incoming:
    hostname: mail.{{external_tld}}
    bind-ipv4: True
    bind-ipv6: False
    # override-ipv4: 123.123.123.123   # override interface bindings to bind to a specific IP
    # override-ipv6: 1234:1234::0


imap:
    # the permission a user must have in authserver to have access to imap. Set to None or empty string to
    # allow all authenticated users to use imap.
    require-permission: imap


smtp:
    # the permission a user must have in authserver to have access to smtp. Set to None or empty string to
    # allow all authenticated users to use smtp.
    require-permission: smtp


# vim: syntax=yaml
