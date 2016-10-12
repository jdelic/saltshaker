
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


imap-incoming:
    hostname: cic.maurusnet.test

# vim: syntax=yaml

