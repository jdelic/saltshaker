# look at local.mailserver-config for a documented full-fledged example

smtp-incoming:
    hostname: cic.maurus.net
    valid-mxs:
        - cic.maurus.net


smtp-outgoing:
    hostname: smtp.maurus.net
    valid-mxs:
        - smtp.maurus.net


imap-incoming:
    hostname: cic.maurus.net

# vim: syntax=yaml

