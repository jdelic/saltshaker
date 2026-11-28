Implementation Overview
=======================

Goal
----
Build a Python CLI tool that initializes the SaltShaker secrets pillar set from scratch. The tool generates:

- Root CA and intermediate (sub) CA using OpenSSL (ECC keys).
- Internal service certificates for ``smtp.local``, ``imap.local``, ``vault.local``, ``postgresql.local``.
- Development wildcard certificate for ``*.{dev_domain}`` signed by the intermediate CA.
- Production wildcard certificate for ``*.{prod_domain}`` via ACME DNS challenge (Certbot or compatible client).
- GPG signing key (public + secret) for Debian repo signing.
- Managed backup/admin GPG public key material for the shared Salt keyring.
- Vagrant preseed minion/master keys for the local test machines plus a testing-domain update in ``vagrant/Vagrantfile``.
- Pillar files in ``srv/pillar/shared/secrets/`` plus CA certs in ``srv/salt/basics/crypto/``.

Scope
-----
- Default target for generated pillars: ``saltshaker/srv/pillar/shared/secrets``.
- Default target for CA certs: ``saltshaker/srv/salt/basics/crypto`` (root CA)
- No network calls unless ACME is explicitly requested by the user.
- Does not manage AWS Vault credentials (explicitly ignored).

CLI Shape
---------
- Entry point: ``saltshaker/tools/saltshaker_secrets.py`` (Python).
- Subcommands: ``init`` (interactive by default), ``update-acme``, ``add-gpg-key``, ``clean``.
- Options every subcommand takes (after the subcommand name): ``--verbose``, ``--color``/``--no-color``,
  ``--no-input`` (never prompt; use defaults where there are any and fail naming the missing option otherwise) and
  ``--work-dir``. ``init``, ``update-acme`` and ``add-gpg-key`` also take ``--secrets-dir``.
- ``--force`` exists only on ``init`` and means "overwrite existing output files". ``update-acme`` always replaces
  ``live-ssl.sls`` and ``add-gpg-key`` always replaces a key with the same ``--name``, because updating is what they
  are for.
- Existing public keys use the same option names everywhere: a source (``keyring``, ``keyserver``, ``url`` or
  ``file``), a key ID for the keyring and keyserver sources, a URL or a file. The source defaults to what the other
  options imply (a key ID alone means the local keyring).

  - ``add-gpg-key [--source S] [--key-id ID | --url URL | --file PATH] [--gpg-home PATH] [--name NAME]``
  - ``init``: ``--backup-key-source`` (also ``generate``), ``--backup-key-id``, ``--backup-key-url``,
    ``--backup-key-file``, ``--backup-key-gpg-home``

- Generated keys: ``--signing-key``/``--no-signing-key`` with ``--signing-key-uid``, ``--signing-key-type``,
  ``--signing-key-length``, ``--signing-key-expire``; ``--backup-key``/``--no-backup-key`` with the same
  ``--backup-key-*`` options plus ``--backup-key-export-secret PATH``/``--no-backup-key-export-secret``.
- Passphrases are never command line options. They come from ``--signing-key-passphrase-file``/
  ``--backup-key-passphrase-file``, from ``SALTSHAKER_SIGNING_KEY_PASSPHRASE``/``SALTSHAKER_BACKUP_KEY_PASSPHRASE``,
  or from a hidden prompt, and they reach gpg on stdin. The "repeat without prompts" command ``init`` prints never
  contains them.
- ``init`` collects every answer (and fetches an existing backup key) before it writes anything, so a missing value
  doesn't leave a half-initialized secrets directory.
- An existing CA, instead of generating a root and intermediate CA:

  - a root CA: ``--root-ca-cert`` and ``--root-ca-key`` (``--root-ca-key-passphrase-file`` or
    ``SALTSHAKER_ROOT_CA_KEY_PASSPHRASE`` for an encrypted key). ``init`` generates an intermediate CA under it.
  - an intermediate CA: ``--intermediate-ca-cert`` and ``--intermediate-ca-key``
    (``--intermediate-ca-key-passphrase-file`` or ``SALTSHAKER_INTERMEDIATE_CA_KEY_PASSPHRASE``), plus ``--root-ca-cert``
    of the root that signed it. ``init`` issues the certificates from it.

  ``init`` checks the keys, the chain and the CA flags first. A root CA already in the crypto dir (like ``maurusnet-rootca.crt``)
  is used in place, and ``config.sls`` lists it in ``install_generated_ca_certs`` only if ``shared/ssl.sls`` doesn't
  install it already.
- Validity: generated root and intermediate CAs 3650 days (``--root-days``, ``--intermediate-days``), service and dev
  wildcard certificates 825 days (``--leaf-days``).
- Without ``--force``, ``init`` refuses before generating anything if any of its output files exists.
- Placeholders and stubs (``live-ssl.sls`` without ACME, ``smtp-relay.sls``, ``gpg-package-signing.sls`` with
  ``--no-signing-key``) are only written when the file doesn't exist, even with ``--force``, so they never replace
  real settings. The backup key is merged into ``gpg-installed-keys.sls`` like ``add-gpg-key`` does.
- Other ``init`` options: ``--dev-domain`` (e.g. ``maurusnet.test``), ``--prod-domains`` (comma list; an empty value
  means none), ``--internal-domain`` (defaults to a sanitized form of the first prod domain such as
  ``maurusnet.internal``), ``--crypto-dir``, ``--config-pillar``, ``--vagrantfile``, ``--preseed-keys-dir``, CA
  subject fields, validity periods, ``--fetch-acme`` and ``--acme-email``. ACME uses the manual DNS challenge only.

Core Outputs
------------
- ``srv/pillar/shared/secrets/common.sls``: intermediate CA cert (for chains).
- ``dev-ssl.sls``: wildcard dev cert + key + chain.
- ``live-ssl.sls``: wildcard prod cert + key + chain (ACME). If ACME not run, create a placeholder with instructions.
- ``smtp.sls`` / ``imap.sls`` / ``vault-ssl.sls`` / ``postgresql.sls``: leaf certs signed by intermediate CA.
- ``smtp-relay.sls``: the external transactional relay, disabled, with a commented example to enable it.
- ``gpg-package-signing.sls``: public + private key blocks.
- ``gpg-installed-keys.sls``: public keys imported into the managed shared keyring. Optional; written by ``init`` and ``add-gpg-key``.
- ``vagrant/preseed-keys/*.pem`` / ``*.pub``: generated RSA keypairs for ``saltmaster.{dev_domain}``, ``test.{dev_domain}`` and ``apps.{dev_domain}``.
- ``vagrant/Vagrantfile``: rewritten so the managed testing-domain constant matches ``--dev-domain``.
- ``srv/salt/basics/crypto/[domain]-rootca-generated.crt``: root CA cert. The suffix keeps it apart from CA files tracked in the repository (``maurusnet-rootca.crt`` is installed on every node for APT repositories). Because the name is stable, ``init`` refuses to run again when it exists, unless ``--force`` is given, which replaces it. Every text file ``init`` writes starts with a comment naming the run (the Unix time in hex).

Secrets Handling
----------------
- Keys are generated on disk, embedded in pillar files as PEM blocks.
- Private key files are stored in a working directory under ``.saltshaker-secrets/`` (gitignored) for user backup.
- The tool can optionally export a ``.tar`` bundle of generated key material.

Assumptions (to confirm)
------------------------
- The intermediate CA should be the signing CA for all internal + dev wildcard certificates.
- Maurus.netowrks Root CA should be installed globally across nodes via ``basics/crypto/ssl.sls`` (``maurusnet-rootca.crt``).
- The new root CA should be installed globally across nodes via ``basics/crypto/ssl.sls`` (``[domain]-rootca-generated.crt``).
- The production wildcard is only retrieved via ACME DNS challenge.

Risks
-----
- Incorrect pillar file structure could break Salt file/contents_pillar references.
- ACME DNS manual challenge requires manual DNS changes and operator time.
- GPG key generation parameters (algo, expiration, UID) may need to match existing CI expectations.
- Backup/admin GPG key import may require network access if fetched from keys.openpgp.org or a URL.
