Concept Deep Dive
=================

Pillar Design Matching
----------------------
SaltShaker expects secrets in ``srv/pillar/shared/secrets`` with a consistent YAML/Jinja layout:

- Each cert file embeds PEM blocks using Jinja ``{% set var = "..." %}`` and ``|indent(12)``.
- Each pillar defines an ``ssl:`` map with ``cert``, ``key``, ``certchain``, and derived ``combined`` values.
- ``shared/secrets/common.sls`` exposes the intermediate CA certificate as ``maurusnet_minionca``.

The tool will mirror this structure so existing Salt states keep working without changes.

PKI Layout
----------
- Root CA (self-signed): installed on all nodes via ``basics/crypto/ssl.sls`` as ``maurusnet-rootca.crt`` (ECC keys).
- Intermediate CA (sub-CA): used for signing internal service certs and dev wildcard cert (ECC keys).
- Leaf certificates: include SANs for service names and Consul-style names where needed.

Recommended SAN sets (mirroring current repo)
---------------------------------------------
- SMTP: ``smtp.local``, ``smtp.internal``, ``smtp.service.consul``.
- PostgreSQL: ``postgresql.local``, ``postgresql.internal``, ``postgresql.service.consul``.
- Vault: ``vault.local``, ``vault.internal``, ``vault.service.consul``, ``vault.{dev_domain}``, ``vault.{prod_domain}``.
- Dev wildcard: ``*.{dev_domain}`` and ``{dev_domain}``.

The tool will allow overrides but default to the current layout.

ACME DNS Flow
-------------
- DNS-01 challenge is required for wildcard certificates.
- The tool uses manual DNS challenge only (``certbot --manual --preferred-challenges dns``).
- The resulting cert, key, and chain are embedded into ``live-ssl.sls``.

GPG Key Lifecycle
-----------------
- Generate a signing key suitable for Debian repo signing.
- Export public key for installation in ``/etc/apt/keyrings``.
- Export private key for CI signing (installed in ``/etc/gpg-managed-keyring``).
- Key material is embedded in ``gpg-package-signing.sls``.

Safety Considerations
---------------------
- Avoid accidental overwrite unless ``--force``.
- Create a local ``.saltshaker-secrets`` folder for backup exports.
- Provide a ``--dry-run`` mode for audit before writing secrets.
