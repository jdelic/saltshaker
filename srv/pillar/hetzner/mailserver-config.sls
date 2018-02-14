{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}
# look at local.mailserver-config for a documented full-fledged example

smtp-incoming:
    hostname: mail.{{external_tld}}


smtp-outgoing:
    hostname: smtp.{{external_tld}}


imap-incoming:
    hostname: mail.{{external_tld}}

# vim: syntax=yaml

