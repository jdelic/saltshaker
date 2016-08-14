
# global states for all nodes

email:
    # no-authentication email sender
    smtp-internal: smtp-relay.service.consul


vault:
    hostname: vault.local
    pinned-ca-cert: /usr/share/ca-certificates/local/maurusnet-rootca.crt


postgresql:
    hostname: postgresql.local

# vim: syntax=yaml

