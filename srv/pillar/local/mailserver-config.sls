
smtp-incoming:
    hostname: mail.maurusnet.test
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


smtp-outgoing:
    hostname: smtp.maurusnet.test
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


# CAREFUL: This is an open relay. Never use 'bind-ip' to bind this to an internet-facing IP!
# By default, this is bound to the internal network interface from the ifassign pillar
smtp-local-relay: {}
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


imap-incoming:
    hostname: cic.maurusnet.test

# vim: syntax=yaml

