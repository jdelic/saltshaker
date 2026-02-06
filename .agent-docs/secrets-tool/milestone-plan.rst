Milestone Plan
==============

M1: Repository Discovery and Alignment
-------------------------------------
- Confirm secrets pillar locations and required files.
- Identify CA cert install paths and pillar references.
- Confirm internal service hostnames and SAN requirements.

M2: CA and Certificate Generation Workflow
------------------------------------------
- Define OpenSSL config templates for root and intermediate CAs (ECC keys).
- Generate root CA (self-signed) and intermediate CA (signed by root).
- Generate leaf certs for:

  - ``smtp.local``
  - ``vault.local``
  - ``postgresql.local``
  - ``*.{dev_domain}``

- Produce PEM chains appropriate for pillar embedding.

M3: GPG Key Creation
--------------------
- Generate a signing key (ed25519 or RSA 4096, confirm preference).
- Export public + secret keys in ASCII armored format.
- Generate ``gpg-package-signing.sls`` pillar structure.

M4: Pillar File Rendering
-------------------------
- Render all secrets pillars with Jinja-friendly PEM blocks.
- Match existing layout in ``srv/pillar/shared/secrets/*.sls``.
- Write CA certs to ``srv/salt/basics/crypto`` as needed.

M5: ACME Integration (Optional)
-------------------------------
- Integrate with Certbot.
- DNS challenge only (manual).
- Store resulting wildcard cert + chain + key into ``live-ssl.sls``.

M6: CLI UX, Safety, and Tests
-----------------------------
- Provide interactive prompts with defaults.
- ``--dry-run`` to print intended files.
- ``--force`` to overwrite.
- Self-checks for file structure and PEM formatting.

Deliverables
------------
- CLI tool under ``saltshaker/bin/`` or ``tools/``.
- Template files for OpenSSL configs and pillar SLS files.
- gpt-docs with overview, plan, concept deep dive.
