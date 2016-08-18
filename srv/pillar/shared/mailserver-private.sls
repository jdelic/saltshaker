
emailstore:
    path: /secure/email


filterstore:
    path: /secure/webfilter


mail-scripts:
    install-dir: /usr/local/mail


imap:
    sslcert: default  # special value "default" means: "use maincert from ssl.init"
    sslkey: default
    sslcert-content: ""  # contents_pillar reference if imap should use a different cert
    sslkey-content: ""


smtp:
    receiver:
        sslcert: default  # see above
        sslkey: default
        sslcert-content: ""
        sslkey-content: ""

    relay:
        sslcert: default  # see above
        sslkey: default
        sslcert-content: ""
        sslkey-content: ""

# vim: syntax=yaml

