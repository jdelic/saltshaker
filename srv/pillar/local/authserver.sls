{% from 'shared/network.sls' import local_domain %}

authserver:
    hostname: auth.maurusnet.test
    protocol: https
    smartstack-hostname: authserver.{{local_domain}}
