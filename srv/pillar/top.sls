
base:
    # assign global shared config to every node
    '*':
        - config
        - allenvs.smartstack
        - shared.authserver
        - shared.saltmine
        - shared.ssl
        - shared.gpg
        - shared.network
        - shared.vault

    'saltmaster*.maurusnet.test':
        - shared.secrets.vault-dev
        - shared.secrets.vault-ssl

    'db.maurusnet.internal':
        - hetzner.vault
        - shared.vault
        - shared.secrets.vault-live
        - shared.secrets.vault-ssl

    'roles:database':
        - match: grain
        - shared.postgresql
        - shared.secrets.postgresql
        - shared.vaultwarden

    'roles:vault':
        - match: grain
        - shared.buildserver
        - shared.vaultwarden
        - shared.vault

    'G@roles:dev or G@roles:buildserver or G@roles:buildworker':
        - match: compound
        - shared.buildserver
        - shared.secrets.gpg-package-signing

    'roles:loadbalancer':
        - match: grain
        - shared.loadbalancer

    'roles:6to4gateway':
        - match: grain
        - shared.6to4

    # spaces ' ' are important after parentheses for the matcher to work (see
    # https://docs.saltstack.com/en/latest/topics/targeting/compound.html)
    'not *.test and ( G@roles:apps or G@roles:loadbalancer or G@roles:mail )':
        - match: compound
        - shared.secrets.live-ssl  # these are wildcard certificates for hostnames on the main domain

    '*.test and ( G@roles:apps or G@roles:loadbalancer or G@roles:mail )':
        - match: compound
        - shared.secrets.dev-ssl  # these are wildcard certificates for hostnames on the main test domain

    '*.test and G@roles:photosync':
        - match: compound
        - local.photosync

    'not *.test and G@roles:photosync':
        - match: compound
        - hetzner.photosync

    '*.test and ( G@roles:webdav or G@roles:authserver )':
        - match: compound
        - local.webdav

    'not *.test and ( G@roles:webdav or G@roles:authserver )':
        - match: compound
        - hetzner.webdav

    'roles:mail':
        - match: grain
        - shared.secrets.smtp
        - shared.mailserver-private

    'roles:pim':
        - match: grain
        - shared.calendar

    'roles:authserver':
        - match: grain
        - shared.vaultwarden

    'roles:nomadserver':
        - match: grain
        - allenvs.nomadserver

    'roles:vaultwarden':
        - match: grain
        - shared.vaultwarden

    'not *.test and G@roles:vault':
        - match: compound
        - hetzner.vault

    # every minion ID not ending in "test" is at Hetzner right now
    'not *.test':
        - match: compound
        - hetzner.authserver
        - hetzner.buildserver
        - hetzner.calendar
        - hetzner.config
        - hetzner.consul
        - hetzner.crypto
        - hetzner.docker
        - hetzner.duplicity
        - hetzner.mailserver-config
        - hetzner.network
        - hetzner.nomad
        - hetzner.postgresql
        - hetzner.ssl
        - hetzner.vaultwarden
        - shared.urls
        - shared.live-users

    # every minion ID ending in ".test" is a local dev environment. We assign all config to these nodes
    # as the list of roles and services changes all the time for testing and development, so it's easier to
    # just assign everything to these nodes.
    '*.test':
        - local.authserver
        - local.buildserver
        - local.calendar
        - local.config
        - local.consul
        - local.crypto
        - local.docker
        - local.duplicity
        - local.mailserver-config
        - local.network
        - local.nomad
        - local.postgresql
        - local.ssl
        - local.vault
        - local.vaultwarden
        # - local.url_overrides
        - shared.urls
        - shared.dev-users


# vim: syntax=yaml
