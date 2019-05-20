{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}
{# {% from 'shared/ssl.sls' import localca_location %} #}

ci:
    enabled: True
    hostname: ci.{{external_tld}}
    protocol: https
    garden-docker-registry: registry-1.docker.io

    # sets PostgreSQL SSL verify settings
    # verify-database-ssl: verify-full
    # use-vault: True

    # the default CIDR for containers run by concourse.ci/garden
    # garden-network-pool: 10.254.0.0/22
