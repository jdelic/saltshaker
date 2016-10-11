postgresql:
    sslcert: /etc/ssl/local/postgresql.crt
    sslkey: /etc/ssl/private/postgresql.key

    # "default" should be interpreted as "use the ssl:service-rootca-cert"
    issuing-ca-cert: default

    hbafile: /etc/postgresql/9.6/main/pg_hba.conf


# vim: syntax=yaml
