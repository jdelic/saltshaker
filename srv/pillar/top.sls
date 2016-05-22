
base:
    # assign global shared config to every node
    '*':
        - shared.global
        - shared.saltmine

    'roles:vault':
        - match: grain
        - shared.vault

    'roles:secure-database':
        - match: grain
        - shared.vault

    # every minion ID not ending in "test" is at Hetzner right now
    '(?!test)$':
        - match: pcre
        - hetzner.mailserver-config
        - hetzner.dns
        - hetzner.network
        - hetzner.consul
        - shared.urls

    # the minion ID starting with "cic" is the main PIM and mail server at Hetzner
    'cic*':
        - shared.mailserver-private
        - shared.ssl
        - shared.casserver

    # every minion ID ending in ".test" is a local dev environment
    '*.test':
        - local.mailserver-config
        - local.dns
        - local.network
        - shared.ssl
        - local.consul
        - local.url_overrides
        # - shared.urls

    # the minion ID starting with "test" is currently the main test VM in my Vagrant environment
    # "shared.ssl" is omitted here, because it's already assigned by '*.test'
    'test*':
        - shared.mailserver-private
        - shared.casserver

# vim: syntax=yaml
