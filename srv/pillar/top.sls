
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
        - local.vault
        - shared.vault
        - shared.secrets.vault-dev
        - shared.secrets.vault-ssl

    'db.maurusnet.internal':
        - hetzner.vault
        - shared.vault
        - shared.secrets.vault-live
        - shared.secrets.vault-ssl

    'E@.+(?!test)$ and G@roles:xenserver':
        - match: compound
        - hetzner.xenserver

    # everything not in Vagrant (*.test) is at Hetzner and everything not a xenserver
    # is a VM
    'E@.*(?!test)$ and not G@roles:xenserver':
        - match: compound
        - hetzner.vm_config

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

    'E@.+(?!test)$ and G@roles:apps or G@roles:loadbalancer or G@roles:mail':
        - match: compound
        - shared.secrets.live-ssl  # these are wildcard certificates for hostnames on the main domain

    '*.test and G@roles:apps or G@roles:loadbalancer or G@roles:mail':
        - match: compound
        - shared.secrets.dev-ssl  # these are wildcard certificates for hostnames on the main test domain

    '*.test and G@roles:goldfish':
        - match: compound
        - local.vault

    'E@.+(?!test)$ and G@roles:goldfish':
        - match: compound
        - hetzner.vault

    '*.test and G@roles:photosync':
        - match: compound
        - local.photosync


    'E@.+(?!test)$ and G@roles:photosync':
        - match: compound
        - hetzner.photosync

    '*.test and G@roles:webdav':
        - match: compound
        - local.webdav

    'E@.+(?!test)$ and G@roles:webdav':
        - match: compound
        - hetzner.webdav

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

    # every minion ID not ending in "test" is at Hetzner right now
    '.+(?!test)$':
        - match: pcre
        - hetzner.wellknown
        - hetzner.mailserver-config
        - hetzner.calendar
        - hetzner.consul
        - hetzner.nomad
        - hetzner.docker
        - hetzner.buildserver
        - hetzner.crypto
        - hetzner.ssl
        - hetzner.authserver
        - hetzner.duplicity
        - shared.urls
        - shared.secrets.live-backup

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
