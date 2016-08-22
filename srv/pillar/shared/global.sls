
# global shared pillars for all nodes

email:
    # no-authentication email sender
    smtp-internal: smtp-relay.service.consul


vault:
    # name of the MySQL/PostgreSQL role managing database credentials on behalf of applications
    # This *must* own all databases managed by Vault.
    managed-database-owner: vaultadmin
    hostname: vault.local
    pinned-ca-cert: /usr/share/ca-certificates/local/maurusnet-rootca.crt


postgresql:
    hostname: postgresql.local

# vim: syntax=yaml

