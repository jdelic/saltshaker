Application deployment and configuration
========================================

The system of deployment relies on the following ideas:

  1. have a build server that builds your applications for CI and CD.

  2. that build server has a (network)-local Vault instance.

  3. that Vault instance can issue certificates from a local "application CA"
     or "deployment environment CA" using the `PKI` secret backend.

  4. The build scripts (using GoPythonGo, for example) request a new
     certificate for each build and put them in the delivery artifact (i.e.
     Docker container or .deb) together with environment variable sources (i.e.
     a file in /etc/defaults loaded by systemd through `EnvironmentFile=`)
     pointing to the file. The certificate has the app name in the `CN`
     attribute.

  5. Each app uses its build certificate issued by the build server to access
     internal services like a local PostgreSQL database (`cert`
     authentication), Vault instance, etc.

Using Vault for resource management
-----------------------------------
If multiple environments are being serviced, they can share an application
root CA with one Vault-managed intermediate CA per environment. Then,
applications built for one environment can also be used in a different
environment, which might be desirable if deployment artifacts are being
"promoted" between environments.  Since Vault is currently
binding policies *to CA certificates*, the application must be at the root
of the CA tree so allow for separating applications access to Vault
resources.

In any case it is good practice to also add intermediaries *for each build
server*, so certificates can be easily revoked if a server gets
compromised or just removed.

```
                   +-------------+  manually managed
                   | myapp       |  CA pathlen: 2
                   +-------------+
                   /      |       \
          +---------+ +-------+ +---------+  manually managed
          |  Stage  | |  Dev  | |   Live  |  intermediaries pathlen: 1
          +---------+ +-------+ +---------+
          /     |       |   |       |     \
      +----+ +----+ +----+ +----+ +----+ +----+  Vault managed build server
      | B1 | | B2 | | B1 | | B2 | | B1 | | B2 |  intermediary. pathlen: 0
      +----+ +----+ +----+ +----+ +----+ +----+
```

Alternatively, each environment could get its own application root CA,
ensuring that each build has unique credentials for its target
environment meaning that builds can't be moved between environments.

```
     +-----------+ +-------------+ +------------+  manually managed CAs
     | myapp Dev | | myapp Stage | | myapp Live |  pathlen: 1
     +-----------+ +-------------+ +------------+
       |       |      |       |      |       |
     +----+ +----+  +----+ +----+  +----+ +----+  Vault managed build
     | B1 | | B2 |  | B1 | | B2 |  | B1 | | B2 |  server intermediaries.
     +----+ +----+  +----+ +----+  +----+ +----+  pathlen: 0
```

If you're willing to rotate intermediaries and transport private keys
between the Vault instances or share a Vault instance between all build
servers, you can cut down the number of CAs to 7 or 6 respectively and
when Vault implements
[#1823](https://github.com/hashicorp/vault/issues/1823), you can cut down
the number of needed CAs even further.

Using SSL authentication with individual resources
--------------------------------------------------
The above works well if Vault issues database credentials to your application,
because as mentioned, Vault assigns policies to *the issuing CA*.

However, if you want to use the build-issued certificates to authenticate to
services directly, like OpenSMTPD and PostgreSQL, you will run into the problem
that each of these services can only trust a single client certificate
authority at a time. So unless you have only a single application,
you have two options:

  1. **Don't use Vault and restructure the CA tree by putting the environment at
     the root(s).**

     ```
             +--------+ +--------+ +--------+  manually managed CAs
             | Dev    | | Stage  | | Live   |  pathlen: 1
             +--------+ +--------+ +--------+
            /     |       |     |      |     \
       +----+ +----+  +----+ +----+  +----+ +----+  Vault managed build
       | B1 | | B2 |  | B1 | | B2 |  | B1 | | B2 |  server intermediaries.
       +----+ +----+  +----+ +----+  +----+ +----+  pathlen: 0

     ```

     PostgreSQL and most other services differentiate permissions through the
     certificate's CN attribute, so in this case in each environment PostgreSQL
     would be configured to trust the environment CA using `ssl_ca_file`, which
     can only take a single value.

  2. **Use multiple trust paths.**

     What this means is that you create one
     environment CA and one application CA. You configure Vault to trust the
     application CA and non-Vault-managed services to trust the environment
     CA. Then you create the **one** intermediary CA, which one doesn't matter.
     **Then you cross-sign the intermediary from the other root CA**. This will
     give you multiple valid certificate chains. You then create **one**
     certificate for each build with **two** valid certificate chains, each
     leading to a different root: *one using the application CA intermediary
     certificate which was signed by the application root CA* and *one using
     the application CA intermediary certificate signed by the environment CA*.
     You ship both chains with your application and configure/program the
     application to present the correct certificate chain when interacting with
     Vault or another service. Note: The intermediary certificates each use
     the same public/private key pair.

     In this case PostgreSQL would be configured to trust the environment root
     CA, allowing it to service multiple different applications and Vault would
     be configured to trust the application root CA allowing it to bind
     policies to the CA.

     ```
          +---------+  +-----------+  manually managed root CAs
          |  Stage  |  | myapp Dev |  pathlen: 1
          +---------+  +-----------+
                |          |
         +----------------------------+
         |  Cross-signed build server |  Vault managed build server
         |  (2 certificates for one   |  intermediary. pathlen: 0
         |  intermediary CA keypair)  |
         +----------------------------+
     ```

     Unfortunately this requires a bit more logic on the application's side as
     it has to present the correct certificate chain when it talks to a
     service.

Why not make this a tidy tree and put a organization root CA at the top?
------------------------------------------------------------------------
Because OpenSSL and by extension most software using it, will follow the trust
path of a SSL client certificate to the "logical end of the trust chain",
*a self-signed CA*. This means that you usually **can't terminate a trust chain
at an intermediary CA**. In other words: Your services would trust every
certificate signed by **any intermediary** under your root CA, not just the PKI
branch represented.

Local development
-----------------
Local development is easy since developers can just use a local
environment that uses username/password auth instead by setting the
required environment variables.

Since the dev/stage/production environments rely on Smartstack, all
applications expect to find their required services on localhost anyway.

For extra security or at least a better audit trail, the live system could
require applications to use their "appcert" to request credentials for their
database through their local Vault instance, thereby leaving an audit trail for
the database credentials.

Command cheatsheet
------------------
```
# Create a "Myapp Dev" CA using openssl or other appropriate software.
# That CA will be installed in the environment's Vault.

# Mount one PKI backend per environment that gets its own builds on this server
# and allow builds to remain valid for 1 year (tune to your specifications)
vault mount -path=pki-myapp-dev -default-lease-ttl=8760h \
    -max-lease-ttl=8760h pki

# Generate an intermediate CA with a 2048 bit key (default)
vault write pki-myapp-dev/intermediate/generate/internal \
    common_name="Myapp Dev Automated Build Server CA X1"

# Sign the intermediate CA using your private Myapp Dev CA
# then write the certificate back to the Vault store
vault write pki-dev/intermediate/set-signed certificate=-

# Cross sign the certificate with your environment CA if you
# want to follow the split model described above!

# You can also use the root certificate with a trustchain
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
