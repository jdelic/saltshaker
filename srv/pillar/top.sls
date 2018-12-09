
base:
    # assign global shared config to every node
    '*':
        - allenvs.wellknown
        - shared.saltmine
        - shared.ssl
        - shared.ssh
        - shared.gpg
        - shared.network

    'saltmaster.maurusnet.test':
        - shared.vault
        - local.vault
        - shared.secrets.vault-dev
        - shared.secrets.vault-ssl

    'roles:database':
        - match: grain
        - shared.postgresql
        - shared.secrets.postgresql
        - shared.authserver

    'roles:vault':
        - match: grain
        - shared.buildserver
        - shared.authserver

    'G@roles:dev or G@roles:buildserver or G@roles:buildworker':
        - match: compound
        - shared.buildserver
        - shared.secrets.gpg-package-signing

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

    'roles:nomadserver':
        - match: grain
        - allenvs.nomadserver

    # every minion ID ending in ".test" is a local dev environment
    '*.test':
        - local.wellknown
        - local.mailserver-config
        - local.calendar
        - local.network
        - local.consul
        - local.nomad
        - local.docker
        - local.buildserver
        - local.crypto
        - local.ssl
        - local.authserver
        - local.duplicity
        # - local.url_overrides
        - shared.urls

# vim: syntax=yaml
