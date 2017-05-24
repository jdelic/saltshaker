
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
        - hetzner.vm_network

    'roles:database':
        - match: grain
        - shared.postgresql
        - shared.secrets.postgresql
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

    'roles:mail':
        - match: grain
        - shared.secrets.smtp

    'roles:pim':
        - match: grain
        - shared.calendar

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
        - hetzner.buildserver
        - hetzner.crypto
        - hetzner.ssl
        - hetzner.authserver
        - shared.urls

    # the minion ID starting with "cic" is the main PIM and mail server at Hetzner
    'mail*':
        - shared.mailserver-private
        - shared.secrets.ssl
        - shared.authserver

    # every minion ID ending in ".test" is a local dev environment
    '*.test':
        - local.wellknown
        - local.mailserver-config
        - local.calendar
        - local.network
        - local.consul
        - local.nomad
        - local.buildserver
        - local.crypto
        - local.ssl
        - local.authserver
        # - local.url_overrides
        - shared.urls

    # the minion ID starting with "test" is currently the main test VM in my Vagrant environment
    # "shared.ssl" is omitted here, because it's already assigned by '*.test'
    'test*':
        - shared.mailserver-private
        - shared.authserver

# vim: syntax=yaml
