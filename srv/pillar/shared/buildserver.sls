{% from 'shared/ssl.sls' import localca_location %}


ci:
    # the default CIDR for containers run by concourse.ci/garden
    backend-network-pool: 10.254.0.0/22

    # sets PostgreSQL SSL verify settings
    verify-database-ssl: verify-full

    use-vault: True


concourse-server:
    atc-port: 38080
