
authserver:
    backend: postgresql
    dbname: authserver
    dbuser: authserver  # unused if vault-manages-database is True


    stored-procedure-api-users:
        - opensmtpd-authserver

# vim: syntax=yaml
