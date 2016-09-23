
authserver:
    backend: postgresql
    dbname: authserver
    dbuser: authserver  # unused if vault-manages-database is True

    opensmtpd-dbuser: opensmtpd-access
# vim: syntax=yaml
