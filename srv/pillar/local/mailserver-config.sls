
smtp-incoming:
    hostname: cic.maurusnet.test
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP
    valid-mxs:
        - cic.maurusnet.test


smtp-outgoing:
    hostname: smtp.maurusnet.test
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP
    valid-mxs:
        - smtp.maurusnet.test


# CAREFUL: This is an open relay. Never use 'bind-ip' to bind this to an internet-facing IP!
smtp-local-relay:
    hostname: smtp.local
    # bind-ip: 123.123.123.123   # override interface bindings to bind to a specific IP


imap-incoming:
    hostname: cic.maurusnet.test

# vim: syntax=yaml

