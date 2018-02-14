{% from 'shared/network.sls' import local_domain %}
{% from 'shared/ssl.sls' import localca_location %}
{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

authserver:
    hostname: auth.{{external_tld}}
    protocol: https
    smartstack-hostname: authserver.{{local_domain}}
    vault-application-ca: {{salt['file.join'](localca_location, 'casserver-ca.crt')}}
    vault-authtype: approle


dkimsigner:
    use-vault: True
    vault-authtype: approle


mailforwarder:
    use-vault: True
    vault-authtype: approle
