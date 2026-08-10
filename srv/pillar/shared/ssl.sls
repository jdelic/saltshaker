# importable variables
{% from 'config.sls' import service_rootca_cert, install_generated_ca_certs %}
{% set certificate_location = '/etc/ssl/local' %}
{% set secret_key_location = '/etc/ssl/private' %}
{% set combined_location = '/etc/ssl/combined' %}
{% set localca_links_location = '/etc/ssl/certs' %}
{% set localca_location = '/usr/share/ca-certificates/local' %}

# common ssl path config
# all certificate secrets are in the saltshaker-secrets git submodule
ssl:
    certificate-location: {{certificate_location}}
    secret-key-location: {{secret_key_location}}
    combined-location: {{combined_location}}
    localca-links-location: {{localca_links_location}}
    localca-location: {{localca_location}}

    # the following defaults should be used by each service which doesn't
    # require or is configured with its own cert.
    filenames:
        default:
            cert: {{salt['file.join'](certificate_location, 'wildcard.crt')}}
            chain: {{salt['file.join'](combined_location, 'wildcard-combined.crt')}}
            key: {{salt['file.join'](secret_key_location, 'wildcard.key')}}
            full: {{salt['file.join'](secret_key_location, '00-wildcard-combined-key.crt')}}

    # The root CA certificate of the PKI issuing service/SSL server certificates in this environment and where
    # it's stored on the nodes (i.e. where other software can find it). You probably want to issue the actual
    # SSL server certificates from an intermediate CA.
    service-rootca-cert: {{service_rootca_cert}}

    # certificates listed here will be installed and symlinked in the locations configured above
    install-ca-certs:
        - salt://basics/crypto/maurusnet-rootca.crt  # maurusnet-rootca is always needed for access to APT repos

    {% if install_generated_ca_certs %}
    install-generated-ca-certs:
    {% for cert in install_generated_ca_certs %}
        - {{cert}}
    {% endfor %}
    {% else %}
    install-generated-ca-certs: []
    {% endif %}

    # Set the following list in a per-environment state
    # environment-rootca-cert: /usr/share/ca-certificates/local/dev-ca.crt
    # install-perenv-ca-certs:
    #    - salt://.../dev-rootca.crt
