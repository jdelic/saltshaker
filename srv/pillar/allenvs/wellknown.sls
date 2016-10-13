# Configuration values that should be accessible to all nodes in all environments.
# This should include configuration values that have no security impact and are widely required to run multiple
# services and can be reasonably expected to remain constant across all deployments.

vault:
    # name of the MySQL/PostgreSQL role managing database credentials on behalf of applications
    # This *must* own all databases managed by Vault.
    managed-database-owner: vaultadmin
    # "default" should be interpreted as "use the ssl:service-rootca-cert"
    pinned-ca-cert: default


postgresql:
    # "default" should be interpreted as "use the ssl:service-rootca-cert"
    pinned-ca-cert: default
