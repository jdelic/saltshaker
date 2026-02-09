{% from "shared/ssl.sls" import localca_location %}
{% from "config.sls" import external_tld %}

authserver:
    backend: postgresql
    use-vault: True
    dbname: authserver
    dbuser: authserver  # unused if vault-manages-database is True

    stored-procedure-api-users:
        - opensmtpd-authserver
        - dovecot-authserver

    # The domain to create for JWT signatures. Changing this allows you to use a higher level domain than the
    # main authserver domain.
    # sso-auth-domain: {{external_tld}}
    # allowing subdomain signing allows the authserver Domain record for tread.mil to sign for a.tread.mil
    # sso-allow-subdomain-signing: False

    # If vault-authtype is 'cert', then this CA is installed into Vault for authenticating authserver.
    vault-application-ca: {{salt['file.join'](localca_location, 'casserver-ca.crt')}}

    # vault-authtype can be 'approle' (read app-id from dynamicsecrets and create secret-id in Vault on the node
    # running the application) or 'cert' which uses a SSL client certificate (often created during build time via
    # GoPythonGo's vaultgetcert tool).
    vault-authtype: approle


dkimsigner:
    dbuser: dkimsigner  # a read-only user for the mailauth_domains table
    use-vault: True
    vault-authtype: approle


mailforwarder:
    dbuser: mailforwarder  # a read-only user for the mailauth_emailalias and mailauth_mailinglist tables
    use-vault: True
    vault-authtype: approle
