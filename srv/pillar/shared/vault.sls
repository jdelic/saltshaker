
vault:
    backend: mysql  # or consul or s3
    path: 'vault/'  # see https://vaultproject.io/docs/config/index.html

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
