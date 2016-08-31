Application deployment and configuration
========================================

The system of deployment relies on the following ideas:

  1. have a build server that builds your applications for CI and CD
  
  2. that build server has a (network)-local Vault instance
  
  3. that Vault instance can issue certificates from a local "application CA"
     using the `PKI` secret backend
     
  4. The build scripts (using GoPythonGo, for example) request a new 
     certificate for each build and put them in the delivery artifact (i.e.
     Docker container or .deb) together with environment variable sources (i.e.
     a file in /etc/defaults loaded by systemd through `EnvironmentFile=`)
     pointing to the file. The certificate has the app name in the `CN` 
     attribute.
     
  5. Each app uses its build certificate issued by the build server to access
     internal services like a local PostgreSQL database (`cert` 
     authentication), Vault instance, etc.
     
  6. If multiple environments are being serviced, they can share a root CA with
     one Vault-managed intermediate CA per environment.
     
  7. Local development is easy since developers can just use a local 
     environment that uses username/password auth instead by setting the 
     required environment variables.
     
  8. Since the dev/stage/production environments rely on Smartstack, all
     applications expect to find their required services on localhost anyway.
     
For extra security or at least a better audit trail, the live system could 
require applications to use their "appcert" to request credentials for their
database through their local Vault instance, thereby leaving an audit trail for
the database credentials.

Command cheatsheet
------------------
```
# Mount one PKI backend per environment that gets its own builds on this server
# and allow builds to remain valid for 1 year (tune to your specifications)
vault mount -path=pki-dev -default-lease-ttl=8760h -max-lease-ttl=8760h pki

# Generate an intermediate CA with a 2048 bit key (default)
vault write pki-dev/intermediate/generate/internal \
    common_name="Automated Build CA X1"

# Sign the intermediate CA using your private CA
# then write the certificate back to the Vault store
vault write pki-dev/intermediate/set-signed certificate=-

# Now this CA certificate should be installed on the relevant servers, e.g. in
# Postgres ssl_ca_cert. You can also use the root certificate with a trustchain
# in the client certificate.
vault write pki-dev/roles/build ttl=8760h allow_localhost=false \
    allow_ip_sans=false server_flag=false client_flag=true \
    allow_any_name=true key_type=rsa

# Request a build certificate for a build
# We "hack" the git hash into a domain name SAN because Vault currently 
# doesn't support freetext SANs. This should run in your build scripts.
vault write pki-dev/issue/build common_name="vaultadmin" \
    alt_names="024572834273498734.git" exclude_cn_from_sans=true
```
