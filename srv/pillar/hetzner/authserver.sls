{% from 'shared/network.sls' import local_domain %}

authserver:
    hostname: auth.maurus.net
    protocol: https
    smartstack-hostname: authserver.{{local_domain}}
