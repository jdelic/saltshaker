{% from "shared/ssl.sls" import certificate_location, secret_key_location %}

emailstore:
    path: /secure/email


imap:
    external:
        sslcert: default  # special value "default" means: "use maincert from ssl.init"
        sslkey: default
        sslcert-content: ''  # contents_pillar reference if imap should use a different cert
        sslkey-content: ''

    internal:
        sslcert: {{salt['file.join'](certificate_location, "imap.local-combined.crt")}}
        sslkey: {{salt['file.join'](secret_key_location, "imap.local.key")}}
        sslcert-content: ssl:imap-local:combined
        sslkey-content: ssl:imap-local:key

    # the permission a user must have in authserver to have access to imap. Set to None or empty string to
    # allow all authenticated users to use imap.
    require-permission: imap

smtp:
    receiver:
        sslcert: default  # see above
        sslkey: default
        sslcert-content: ''
        sslkey-content: ''

    relay:
        sslcert: default  # see above
        sslkey: default
        sslcert-content: ''
        sslkey-content: ''

    internal-relay:
        sslcert: {{salt['file.join'](certificate_location, "smtp.local-combined.crt")}}
        sslkey: {{salt['file.join'](secret_key_location, "smtp.local.key")}}
        sslcert-content: ssl:smtp-local:combined
        sslkey-content: ssl:smtp-local:key

    # the permission a user must have in authserver to have access to smtp. Set to None or empty string to
    # allow all authenticated users to use smtp.
    require-permission: smtp

    # `relay-via` relays all email from OpenSMTPD via a third party smarthost with optional authentication.
    # `transactional-relay-via` relays only "transactional" email which is non-forwarded email on domains
    # that have the can_use_transactional_relay flag set in authserver and are routed via mailforwarder.
    # Setting `enable-transactional-relay` will add configuration for a second relay in OpenSMTPD.

    #relay-via:
    #    url: smtps://ses@host/
    #    auth: ses=user:password
    #enable-transactional-relay: True
    #transactional-relay-via:
    #    url: smtps://ses-transactional@host/
    #    auth: ses-transactional=user:password

mailforwarder:
    transactional-relay-port: 10047

# vim: syntax=yaml

