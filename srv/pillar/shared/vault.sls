#
# This pillar configures the Vault secret storage system which is installed on servers with the
# "vaultserver" role.
# https://vaultproject.io/docs/config/index.html
#

vault:
    # "mysql" or "consul" or "s3". Only "consul" supports redundancy (more than one vault server in the cluster
    # with leader elections. However, "consul" is *only* a good choice if your consul nodes run on multiple
    # physical machines.
    backend: mysql
    kvpath: 'vault/'  # see https://vaultproject.io/docs/config/index.html

    sslcert: /etc/ssl/local/vault.crt
    sslkey: /etc/ssl/private/vault.key

    mysql:
        dbname: vault  # only needed for mysql backend
        dbuser: vault  # the password is created via the dynamicpasswords ext_pillar

    s3:
        bucket: vault
        aws-region: us-east-1
        aws-accesskey: 'AABC...'
        aws-secretkey: 'AABC...'

    enable-telemetry: False  # if you set this to True then you need to uncomment and provide one the following:
    #telemetry:
    #    statsite:  # the address of a statsite instance
    #    statsd:    # a statsd endpoint
    #    disable_hostname: False  # whether Vault should prepend stats with the machine's hostname
