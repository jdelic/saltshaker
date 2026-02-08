Implementation Overview
=======================

Goal
----
Build a Python CLI tool that initializes the SaltShaker secrets pillar set from scratch. The tool generates:

- Root CA and intermediate (sub) CA using OpenSSL (ECC keys).
- Internal service certificates for ``smtp.local``, ``vault.local``, ``postgresql.local``.
- Development wildcard certificate for ``*.{dev_domain}`` signed by the intermediate CA.
- Production wildcard certificate for ``*.{prod_domain}`` via ACME DNS challenge (Certbot or compatible client).
- GPG signing key (public + secret) for Debian repo signing.
- Pillar files in ``srv/pillar/shared/secrets/`` plus CA certs in ``srv/salt/basics/crypto/``.

Scope
-----
- Default target for generated pillars: ``saltshaker/srv/pillar/shared/secrets``.
- Default target for CA certs: ``saltshaker/srv/salt/basics/crypto`` (root CA) and ``.../dev/dev-ca.crt`` (intermediate/dev CA).
- No network calls unless ACME is explicitly requested by the user.
- Does not manage AWS Vault credentials (explicitly ignored).

CLI Shape
---------
- Entry point: ``saltshaker/tools/saltshaker_secrets.py`` (Python).
- Primary command: ``init`` (interactive by default).
- Options for non-interactive use:

  - ``--dev-domain`` (single dev/test domain, e.g. ``maurusnet.test``)
  - ``--prod-domains`` (comma list, e.g. ``maurus.net``)
  - ``--secrets-dir`` (defaults to secrets submodule)
  - ``--crypto-dir`` (defaults to basics/crypto)
  - ``--force`` (overwrite)
  - ``--acme-email``
  - ACME uses manual DNS challenge only

Core Outputs
------------
- ``srv/pillar/shared/secrets/common.sls``: intermediate CA cert (for chains).
- ``dev-ssl.sls``: wildcard dev cert + key + chain.
- ``live-ssl.sls``: wildcard prod cert + key + chain (ACME). If ACME not run, create a placeholder with instructions.
- ``smtp.sls`` / ``vault-ssl.sls`` / ``postgresql.sls``: leaf certs signed by intermediate CA.
- ``gpg-package-signing.sls``: public + private key blocks.
- ``srv/salt/basics/crypto/maurusnet-rootca.crt``: root CA cert.
- ``srv/salt/basics/crypto/dev/dev-ca.crt``: intermediate CA cert (dev/infra CA).

Secrets Handling
----------------
- Keys are generated on disk, embedded in pillar files as PEM blocks.
- Private key files are stored in a working directory under ``.saltshaker-secrets/`` (gitignored) for user backup.
- The tool can optionally export a ``.tar`` bundle of generated key material.

Assumptions (to confirm)
------------------------
- The intermediate CA should be the signing CA for all internal + dev wildcard certificates.
- Root CA should be installed globally across nodes via ``basics/crypto/ssl.sls`` (``maurusnet-rootca.crt``).
- The dev CA cert should be installed for the local environment via ``srv/pillar/local/ssl.sls`` (already references ``dev-ca.crt``).
- The production wildcard is only retrieved via ACME DNS challenge.

Risks
-----
- Incorrect pillar file structure could break Salt file/contents_pillar references.
- ACME DNS manual challenge requires manual DNS changes and operator time.
- GPG key generation parameters (algo, expiration, UID) may need to match existing CI expectations.
