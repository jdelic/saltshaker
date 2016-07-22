# common ssl path config
# all certificate secrets are in the saltshaker-secrets git submodule
ssl:
    certificate-location: /etc/ssl/local
    secret-key-location: /etc/ssl/private

    # the following defaults should be used by each service which doesn't
    # require or is configured with its own cert.
    default-cert: /etc/ssl/local/wildcard.crt
    default-cert-combined: /etc/ssl/local/wildcard-combined.crt
    default-cert-key: /etc/ssl/private/wildcard.key
    default-cert-full: /etc/ssl/private/wildcard-combined-key.crt
