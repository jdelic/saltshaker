haproxy:
    bind-ipv4: True
    bind-ipv6: True
    acme-directory: https://acme-v02.api.letsencrypt.org/directory
    acme-account-key: /etc/haproxy/acme/letsencrypt.account.key
    acme-cert-dir: /etc/haproxy/acme/certs
    acme-dump-socket: /run/haproxy/admin-external.sock
    # acme-contact: admin@example.com
    # override-ipv4: 123.0.0.1
    # override-ipv6: 2001:db8::1


envoy:
    bind-ipv4: True
    bind-ipv6: True
    # override-ipv4: 123.0.0.1
    # override-ipv6: 2001:db8::1
