{% from 'shared/network.sls' import local_domain %}

authserver:
    hostname: auth.maurus.net
    protocol: https
    smartstack-hostname: authserver.{{local_domain}}
    vault-application-ca: {{salt['file.join'](localca_location, 'casserver-ca.crt')}}
