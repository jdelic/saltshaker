#
# Centralized configuration for domain/TLD values and user definitions.
# Update these values per environment/branch as needed.
#

{% set internal_domain = "internal" %}
{% set local_domain = "local" %}
{% set external_tld = "maurus.net" %}
{% set service_rootca_cert = "/usr/share/ca-certificates/local/maurusnet-rootca.crt" %}
{% set install_generated_ca_certs = [] %}

config:
    domains:
        internal: {{ internal_domain }}
        local: {{ local_domain }}
        external: {{ external_tld }}

# Users to be created on servers are defined in dev-users.sls/live-users.sls
users: {}

# vim: syntax=yaml
