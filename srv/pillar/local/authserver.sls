{% from 'shared/network.sls' import local_domain %}
{% from 'shared/ssl.sls' import localca_location %}
{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

authserver:
    hostname: auth.{{external_tld}}

    # The domain to create for JWT signatures. Changing this allows you to use a higher level domain than the
    # main authserver domain.
    # sso-auth-domain: {{external_tld}}
    # allowing subdomain signing allows the authserver Domain record for tread.mil to sign for a.tread.mil
    # sso-allow-subdomain-signing: False

    protocol: https
    smartstack-hostname: authserver.{{local_domain}}

    # If vault-authtype is 'cert', then this CA is installed into Vault for authenticating authserver.
    # vault-application-ca: {{salt['file.join'](localca_location, 'casserver-ca.crt')}}

    # vault-authtype can be 'approle' (read app-id from dynamicsecrets and create secret-id in Vault on the node
    # running the application) or 'cert' which uses a SSL client certificate (often created during build time via
    # GoPythonGo's vaultgetcert tool).
    vault-authtype: approle


dkimsigner:
    use-vault: True
    vault-authtype: approle


mailforwarder:
    use-vault: True
    vault-authtype: approle
