
authserver:
    backend: postgresql
    use-vault: True
    dbname: authserver
    dbuser: authserver  # unused if vault-manages-database is True

    stored-procedure-api-users:
        - opensmtpd-authserver
        - dovecot-authserver


dkimsigner:
    dbuser: dkimsigner  # a read-only user for the mailauth_domains table


mailforwarder:
    dbuser: mailforwarder  # a read-only user for the mailauth_emailalias and mailauth_mailinglist tables

# vim: syntax=yaml
