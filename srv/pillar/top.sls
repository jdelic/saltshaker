
base:
    # assign global shared config to every node
    '*':
        - shared.global
        - shared.saltmine
        - shared.ssl
        - shared.ssh
        - shared.gpg

    'saltmaster.maurusnet.test':
        - local.vault
        - shared.secrets.vault-dev
        - shared.secrets.vault-ssl

    'saltmaster.maurus.net':
        - hetzner.vault
        - shared.secrets.vault-live
        - shared.secrets.vault-ssl

    'roles:database':
        - match: grain
        - shared.postgresql
        - shared.secrets.postgresql
        - shared.authserver

    'roles:dev':
        - match: grain
        - shared.secrets.concourse
        - shared.secrets.gpg_package_signing

    'roles:apps':
        - match: grain
        - shared.secrets.ssl

    'roles:mail':
        - match: grain
        - shared.secrets.ssl

    'roles:loadbalancer':
        - match: grain
        - shared.secrets.ssl

    'roles:authserver':
        - match: grain
        - shared.authserver

    # every minion ID not ending in "test" is at Hetzner right now
    '(?!test)$':
        - match: pcre
        - hetzner.mailserver-config
        - hetzner.dns
        - hetzner.network
        - hetzner.consul
        - hetzner.hostnames
        - shared.urls

    # the minion ID starting with "cic" is the main PIM and mail server at Hetzner
    'cic*':
        - shared.mailserver-private
        - shared.secrets.ssl
        - shared.authserver

    # every minion ID ending in ".test" is a local dev environment
    '*.test':
        - local.mailserver-config
        - local.dns
        - local.network
        - local.consul
        - local.hostnames
        - local.url_overrides
        # - shared.urls

    # the minion ID starting with "test" is currently the main test VM in my Vagrant environment
    # "shared.ssl" is omitted here, because it's already assigned by '*.test'
    'test*':
        - shared.mailserver-private
        - shared.authserver

# vim: syntax=yaml
