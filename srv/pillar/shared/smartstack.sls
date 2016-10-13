{% from 'shared/network.sls' import local_domain %}
# global shared pillars for all nodes

smtp:
    # no-authentication email sender
    smartstack-hostname: smtp.{{local_domain}}


vault:
    smartstack-hostname: vault.{{local_domain}}


postgresql:
    smartstack-hostname: postgresql.{{local_domain}}

# vim: syntax=yaml

