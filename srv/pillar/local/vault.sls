{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}
{% from 'shared/ssl.sls' import localca_location, certificate_location, secret_key_location %}

#
# This pillar configures the Vault secret storage system which is installed on servers with the
# "vaultserver" role.
# https://vaultproject.io/docs/config/index.html
#

vault:
    # "mysql", "postgresql" or "consul" or "s3". Only "consul" supports redundancy (more than one vault server
    # in the cluster with leader elections. However, "consul" is *only* a good choice if your consul nodes run
    # on multiple physical machines.
    backend: postgresql

    # possible values: "disable" and "verify-full"
    verify-backend-ssl: verify-full

    kvpath: 'vault/'  # see https://vaultproject.io/docs/config/index.html

    # 'default' should be interpreted as a reference to the default certificates in ssl.sls
    # but Vault cannot operate without SSL
    sslcert: {{salt['file.join'](certificate_location, 'vault.crt')}}
    sslkey: {{salt['file.join'](secret_key_location, 'vault.key')}}

    mysql:
        dbname: vault  # only needed for mysql backend
        dbuser: vault  # the password is created via the dynamicsecrets ext_pillar

    postgres:
        dbname: vault  # only needed for postgres backend
        dbuser: vault  # the password is created via the dynamicsecrets ext_pillar

    s3:
        bucket: vault-dev
        aws-region: eu-central-1
        # put these into your "secrets" pillar!
        # aws-accesskey: 'AABC...'
        # aws-secretkey: 'akaio13...'

    enable-telemetry: False  # if you set this to True then you need to uncomment and provide one the following:
    #telemetry:
    #    statsite:  # the address of a statsite instance
    #    statsd:    # a statsd endpoint
    #    disable_hostname: False  # whether Vault should prepend stats with the machine's hostname

    # default_lease_ttl: (default: 30 days)
    # max_lease_ttl: (default: 1 year)
    hostname: vault.{{external_tld}}

    # On local test machines, do not encrypt Vault keys
    encrypt-vault-keys-with-gpg: False
