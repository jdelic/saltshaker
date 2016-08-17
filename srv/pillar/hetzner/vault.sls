#
# This pillar configures the Vault secret storage system which is installed on servers with the
# "vaultserver" role.
# https://vaultproject.io/docs/config/index.html
#

# look at local.vault for a full-fledged example config!

vault:
    backend: s3
    verify-backend-ssl: verify-full

    kvpath: 'vault/'  # see https://vaultproject.io/docs/config/index.html

    sslcert: /etc/ssl/local/vault.crt
    sslkey: /etc/ssl/private/vault.key

    s3:
        bucket: vault
        aws-region: eu-central-1
        # S3 secrets config moved to saltshaker-secrets

    enable-telemetry: False
