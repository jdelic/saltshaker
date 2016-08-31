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
     one intermediate CA per environment.
     
  7. Local development is easy since developers can just use a local 
     environment that uses username/password auth instead
     
  8. Since the dev/stage/production environments rely on Smartstack, all
     applications expect to find their required services on localhost anyway.
     
For extra security or at least a better audit trail, the live system could 
require applications to use their "appcert" to request credentials for their
database through their local Vault instance, thereby leaving an audit trail for
the database credentials.
