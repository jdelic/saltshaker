{% from 'config.sls' import local_domain %}

# Configuration values that should be accessible to all nodes in all environments.
# This should include configuration values that have no security impact and are widely required to run multiple
# services and can be reasonably expected to remain constant across all deployments.

smartstack-services:
    vault:
        smartstack-hostname: vault.{{local_domain}}


    postgresql:
        # "default" should be interpreted as "use the ssl:service-rootca-cert"
        smartstack-hostname: postgresql.{{local_domain}}


    smtp:
        # no-authentication email sender
        smartstack-hostname: smtp.{{local_domain}}


    authserver:
        protocol: https
        smartstack-hostname: authserver.{{local_domain}}


# vim: syntax=yaml
