{% from 'shared/network.sls' import local_domain %}
{% from 'shared/ssl.sls' import localca_location %}

authserver:
    hostname: auth.maurus.net
    protocol: https
    smartstack-hostname: authserver.{{local_domain}}
    vault-application-ca: {{salt['file.join'](localca_location, 'casserver-ca.crt')}}
    vault-authtype: ssl


dkimsigner:
    use-vault: True
    vault-authtype: ssl


mailforwarder:
    use-vault: True
    vault-authtype: ssl
