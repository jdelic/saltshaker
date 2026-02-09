{% from 'config.sls' import external_tld %}
{% from 'shared/ssl.sls' import localca_location, certificate_location, secret_key_location %}
#
# This pillar configures the Vault secret storage system which is installed on servers with the
# "vaultserver" role.
# https://vaultproject.io/docs/config/index.html
#

# look at local.vault for a full-fledged example config pillar!

vault:
    # Set this to 'True' to make this Salt config initialize Vault automatically
    initialize: True
    create-database: True
    encrypt-vault-keys-with-gpg: 23FC12D75291ED448C0728C877C339AB7CDC4589

    backend: postgresql
    verify-backend-ssl: verify-full

    kvpath: 'vault/'  # see https://vaultproject.io/docs/config/index.html

    sslcert: {{salt['file.join'](certificate_location, 'vault.crt')}}
    sslkey: {{salt['file.join'](secret_key_location, 'vault.key')}}

    postgres:
        dbname: vault  # only needed for postgres backend
        dbuser: vault  # the password is created via the dynamicsecrets ext_pillar

    enable-telemetry: False

    # name of the MySQL/PostgreSQL role managing database credentials on behalf of applications
    # This *must* own all databases managed by Vault.
    managed-database-owner: vaultadmin

