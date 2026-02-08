
base:
    # assign global shared config to every node
    '*':
        - config
        - allenvs.smartstack
        - shared.saltmine
        - shared.ssl
        - shared.gpg
        - shared.network
        - shared.vault

    'saltmaster*.maurusnet.test':
        - shared.secrets.vault-dev
        - shared.secrets.vault-ssl

    'roles:database':
        - match: grain
        - shared.postgresql
        - shared.secrets.postgresql
        - shared.authserver
        - shared.vaultwarden

    'roles:vault':
        - match: grain
        - shared.buildserver
        - shared.authserver
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

    '*.test and ( G@roles:webdav or G@roles:authserver )':
        - match: compound
        - local.webdav

    'roles:mail':
        - match: grain
        - shared.secrets.smtp
        - shared.mailserver-private
        - shared.authserver

    'roles:pim':
        - match: grain
        - shared.calendar
        - shared.authserver

    'roles:authserver':
        - match: grain
        - shared.authserver
        - shared.vaultwarden

    'roles:nomadserver':
        - match: grain
        - allenvs.nomadserver

    'roles:vaultwarden':
        - match: grain
        - shared.vaultwarden

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
        # - local.url_overrides
        - shared.urls
        - shared.dev-users

    # every non-test node gets the live user set
    'not *.test':
        - match: compound
        - shared.live-users

# vim: syntax=yaml
