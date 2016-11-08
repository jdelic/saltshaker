# importable variables
{% set certificate_location = '/etc/ssl/local' %}
{% set secret_key_location = '/etc/ssl/private' %}
{% set localca_links_location = '/etc/ssl/certs' %}
{% set localca_location = '/usr/share/ca-certificates/local' %}

# common ssl path config
# all certificate secrets are in the saltshaker-secrets git submodule
ssl:
    certificate-location: {{certificate_location}}
    secret-key-location: {{secret_key_location}}
    localca-links-location: {{localca_links_location}}
    localca-location: {{localca_location}}

    # the following defaults should be used by each service which doesn't
    # require or is configured with its own cert.
    filenames:
        default-cert: {{salt['file.join'](certificate_location, 'wildcard.crt')}}
        default-cert-combined: {{salt['file.join'](certificate_location, 'wildcard-combined.crt')}}
        default-cert-key: {{salt['file.join'](secret_key_location, 'wildcard.key')}}
        default-cert-full: {{salt['file.join'](secret_key_location, 'wildcard-combined-key.crt')}}

    # The root CA certificate of the PKI issuing service/SSL server certificates in this environment and where
    # it's stored on the nodes (i.e. where other software can find it). You probably want to issue the actual
    # SSL server certificates from an intermediate CA.
    service-rootca-cert: {{salt['file.join'](localca_location, 'maurusnet-rootca.crt')}}

    # certificates listed here will be installed and symlinked in the locations configured above
    install-ca-certs:
        - salt://crypto/maurusnet-rootca.crt
        - salt://crypto/maurusnet-minionca.crt

    # Set the following list in a per-environment state
    # environment-rootca-cert: /usr/share/ca-certificates/local/dev-ca.crt
    # install-perenv-ca-certs:
    #    - salt://.../dev-rootca.crt
