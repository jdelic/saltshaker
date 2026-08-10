{% from "shared/ssl.sls" import combined_location, secret_key_location %}

emailstore:
    path: /secure/email


ssl:
    filenames:
        imap-local:
            chain: {{salt['file.join'](combined_location, "imap.local-combined.crt")}}
            key: {{salt['file.join'](secret_key_location, "imap.local.key")}}
        smtp-local:
            chain: {{salt['file.join'](combined_location, "smtp.local-combined.crt")}}
            key: {{salt['file.join'](secret_key_location, "smtp.local.key")}}

    sources:
        imap-local:
            chain: ssl:imap-local:combined
            key: ssl:imap-local:key
        smtp-local:
            chain: ssl:smtp-local:combined
            key: ssl:smtp-local:key


imap:
    external:
        ssl: default  # special value "default" means: "use ssl:filenames:default"

    internal:
        ssl: imap-local


smtp:
    receiver:
        ssl: default  # see above

    relay:
        ssl: default  # see above

    internal-relay:
        ssl: smtp-local

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
