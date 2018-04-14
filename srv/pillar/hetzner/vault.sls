{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}
{% from 'shared/ssl.sls' import localca_location, certificate_location, secret_key_location %}
#
# This pillar configures the Vault secret storage system which is installed on servers with the
# "vaultserver" role.
# https://vaultproject.io/docs/config/index.html
#

# look at local.vault for a full-fledged example config pillar!

vault:
    backend: s3
    verify-backend-ssl: verify-full

    kvpath: 'vault/'  # see https://vaultproject.io/docs/config/index.html

    sslcert: {{salt['file.join'](certificate_location, 'vault.crt')}}
    sslkey: {{salt['file.join'](secret_key_location, 'vault.key')}}

    s3:
        bucket: maurusnet-vault
        aws-region: eu-central-1
        # S3 secrets config moved to saltshaker-secrets

    enable-telemetry: False
    hostname: vault.{{external_tld}}
