# jdelic's Saltshaker

This is a collection of saltstack formulae designed to bring up an small
hosting environment for multiple applications and services. The hosting
environment is reusable, the services are primarily there to fulfill my needs
and allow experimentation with different DevOps setups.

Cloning this repository is a good basis for your own Salt setup as it
implements a number of best practices I discovered and includes a fully
fledged [SmartStack](http://nerds.airbnb.com/smartstack-service-discovery-cloud/)
implementation for internal, external and cross-datacenter services.

It also builds on the principles I have documented in my
[GoPythonGo](https://github.com/gopythongo/gopythongo) build and deployment
process.

It has full support for [Vagrant](http://vagrantup.com/), allowing easy
testing of new functionality and different setups on your local machine before
deploying them. Personally, I'm deploying this configuration on my laptop
using Vagrant, on Digital Ocean and my own server on Hetzner which I configure
with a XEN Hypervisor running VMs for all my development needs.

Everything in here is based around **Debian 9.0 Stretch** (i.e. requires
systemd and uses Debian package naming).

Using these salt formulae you can bring up:

  * a primarily Python/Django based application environment

  * a [Hashicorp Nomad](https://nomadproject.io/) based Docker/application
    cluster that integrates with the Consul-Smartstack implementation and
    provides easy application deployment.

  * including a consul/consul-template/haproxy based
    [smartstack](http://nerds.airbnb.com/smartstack-service-discovery-cloud/)
    implementation for service discovery (you can find an extracted stand-
    alone version of that in my
    [consul-smartstack repository](https://github.com/jdelic/consul-smartstack).

  * a PostgreSQL database configuration for a "fast" database and a separate
    tablespace on an encrypted partition

  * a [Concourse.CI](http://concourse.ci/) build server environment for
    your projects

  * an HAProxy based reverse proxying load balancer for applications based
    around the same smartstack implementation

It also contains configuration for

  * a fully fledged PIM+Mail server with encrypted storage (based on
    [Radicale](http://radicale.org/), [Dovecot](http://dovecot.org) and
    [OpenSMTPD](https://www.opensmtpd.org/))

  * single-sign-on for Radicale, Dovecot and OpenSMTPD, other web applications
    and even PAM using a single database for authentication and providing
    OAuth2, CAS and SAML (through Dovecot). This is provided through
    authserver, a separate Django application written by me.

The salt configuration is pretty modular, so you can easily just use this
repository to bring up a GoPythonGo build and deployment environment without
any of the other stuff.


## Configuration deployment

Deploying this salt configuration requires you to:

  1. create a bootstrap server (for example a Amazon EC2 instance, a
     Dom0 VM on your own Xen server or a Digital Ooean droplet)

  2. Assign that server the `saltmaster` and `consulserver` roles
     ```
     mkdir -p /etc/roles.d
     touch /etc/roles.d/saltmaster
     touch /etc/roles.d/consulserver
     ```

  3. check out the saltshaker repository
     ```
     cd /opt
     git clone https://github.com/jdelic/saltshaker
     ln -sv /opt/saltshaker/srv/salt /srv/salt
     ln -sv /opt/saltshaker/srv/pillar /srv/pillar
     ln -sv /opt/saltshaker/srv/reactor /srv/reactor
     ln -sv /opt/saltshaker/srv/salt-modules /srv/salt-modules
     mkdir -p /etc/salt/master.d /etc/salt/minion.d
     ln -sv /opt/saltshaker/etc/salt-master/master.d/saltshaker.conf /etc/salt/master.d/saltshaker.conf
     ln -sv /opt/saltshaker/etc/salt-minion/minion.d/saltshaker.conf /etc/salt/minion.d/saltshaker.conf
     ```

  4. Install Salt
     ```
     wget -O /tmp/install_salt.sh https://bootstrap.saltstack.com
     chmod 700 /tmp/install_salt.sh
     /tmp/install_salt.sh -M -P
     ```

  5. Edit the Pillar data in `/srv/pillar`. You **must** create a network
     configuration for your environment (see *Networking* below) and assign
     it to your systems in `top.sls`. It's especially important to select
     a count of consul server instances (3 are recommended for a production
     environment). You also **must** provide a `secrets` pillar that contains
     SSL certificates and such things.

  6. Run `salt-call state.highstate -l debug` on your master to bring it up.

  7. Bring up additional nodes (at least the count of consul server instances)

  8. Assign them roles, install the salt minion using `install_salt.sh -P` and
     call state.highstate. It's obviously much better to *automate* this step.
     I did so for the XEN Hypervisor for example using the scripts in `role.d`
     together with `xen-create-image`.


# The secrets pillar

You should clone the saltshaker repository and then as a first step, replace
the git submodule in `srv/pillar/shared/secrets` with your own **private Git
repository**.

For my salt states to work, you **must** provide your own`shared.secrets`
pillar in `srv/pillar/shared/secrets` that **must** contain the following
pillars, unless you rework the salt states to use different ones. I use a
wildcard certificate for my domains and the configuration pillars for
individual servers allow you to specify pillar references to change what
certificates are used, but in the default configuration most services refer
to the ``maincert``, which is the wildcard certificate:

In `shared.secrets.ssl`:
  * `ssl:maincert:cert` - The public X.509 SSL certificate for your domain.
    You can replace these with cert pillars for your individual domain.
  * `ssl:maincert:key:` - The private key for your SSL certificate without a
    passphrase. You can replace this with key pillars for your individual
    domain.
  * `ssl:maincert:certchain` - The X.509 certificates tying your CA to a
    browser-accredited CA, if necessary.
  * `ssl:maincert:combined` - A concatenation of `:cert` and `:certchain`.
  * `ssl:maincert:combined-key` - A concatenation of `:cert`, `:certchain` and
    `:key`.

In `shared.secrets.vault`:
  * `ssl:vault:cert` - the public X.509 SSL certificate used by the `vault`
    role/server. Should contain SANs for `vault.local` resolving to `127.0.0.1`
    (see notes on the `.local` and `.internal` domains under "Networking"
    below).
  * `ssl:vault:key` - its private key
  * `ssl:vault:certchain` - its CA chain
  * `ssl:vault:combined` - A concatenation of `:cert` and `:certchain`
  * `ssl:vault:combined-key` - A concatenation of `:cert` and `:certchain` and
    `:key`.
  * `vault:s3:aws-accesskey` - The access key for an IAM role that can be used
    for the Vault S3 backend (if you want to use that). Must have read/write
    access to a S3 bucket.
  * `vault:s3:aws-secretkey` - the secret key corresponding to the access key
    above.

In `shared.secrets.concourse`:
  * `ssh:concourse:public` - A SSH2 public RSA key for the concourse.ci TSA SSH
    host.
  * `ssh:concourse:key` - The private key for the public host key.

In `shared.secrets.postgresql`:
  * `ssl:postgresql:cert,key,certchain,combined,combined-key` in the same
    structure as the SSL certs mentioned above, containing a SSL cert used to
    encrypt database traffic through `postgresql.local`.

I manage these pillars in a private Git repository that I clone to
`srv/pillar/shared/secrets` as a Git submodule. To keep the PEM encoded
certificates and keys in the pillar file, I use the following trick:

```
# pillar file
{% set mycert = "
-----BEGIN CERTIFICATE-----
MIIFBDCCAuwCAQEwDQYJKoZIhvcNAQELBQAwgdgxCzAJBgNVBAYTAkRFMQ8wDQYD
...
-----END CERTIFICATE-----"|indent(12) %}

# because we're using the indent(12) template filter we can then do:
ssl:
    maincert:
        cert: | {{mycert}}
```

## shared.secrets: The managed GPG keyring

The salt config also contains states which manage a shared GPG keyring. All
keys added to the dict pillar `gpg:keys` are iterated by the `crypto.gpg`
state and put into a GPG keyring accessible only by `root` and the user
group`gpg-access`. There is a parallel pillar called `gpg:fingerprints`
that is used to check whether a key has already been added. The file system
location of the shared keyring is set by the `gpg:shared-keyring-location`
pillar, which by default is `/etc/gpg-managed-keyring`.


# Server configuration

### Pillar overrides

## Disks

### /secure


## The roledir grain


## Available roles


# Salt modules


## The dynamicsecrets Pillar

This is a Pillar module that can be configured on the master to provide
dynamically generated passwords and RSA keys across an environment managed by
a Salt master. The secrets are stored in a single **unencrypted** sqlite 
database file that can (and should) be easily backed up (default path: 
`/etc/salt/dynamicsecrets.sqlite`). This should be used for non-critical 
secrets that must be shared between minions and/or where a more secure solution
like Hashicorp's Vault is not yet applicable.

**To be clear:** The purpose of `dynamicsecrets` is to help bootstrap a cluster 
of servers where a number of initial secrets must be set and "remembered" 
across multiple nodes that are configured with Salt. This solution is *better*
than putting hardcoded secrets in your configuration management, but you should
really only rely on it to bootstrap your way to an installation of Hashicorp
Vault or another solution that solves the secret introduction problem 
comprehensively!

Secrets from the pillar are assigned to the "roles" grain or minion ids and
are therefor only rendered to assigned minions from the master.

```yaml
# Example configuration
    # Extension modules
    extension_modules: /srv/salt-modules

    ext_pillar:
    - dynamicsecrets:
        config:
            approle-auth-token:
                type: uuid
            concourse-encryption:
                length: 32
            concourse-hostkey:
                length: 2048
                type: rsa
            consul-acl-token:
                type: uuid
                unique-per-host: True
            consul-encryptionkey:
                encode: base64
                length: 16
        grainmapping:
            roles:
                authserver:
                    - approle-auth-token
        hostmapping:
            '*':
                - consul-acl-token
```

For `type: password` the Pillar will simply contain the random password string.
For `type: uuid` the Pilar will return a UUID4 built from a secure random 
source (as long as the OS provides one).
For `type: rsa` the Pillar will return a `dict` that has the following
properties:
 * `public_pem` the public key in PEM encoding
 * `public` the public key in `ssh-rsa` format
 * `key` the private key in PEM encoding

The dynamicsecrets pillar has been extracted [into it's own project at 
jdelic/dynamicsecrets/](https://github.com/jdelic/dynamicsecrets).


# Deploying applications

## Service deployment "through" salt and "on" servers configured by salt

First off, don't get confused by the service configuration and discovery states
that seem to be "interwoven" in this repository. The whole setup is meant to

  * allow applications to be deployed from .debs or Docker containers, being
    discovered through consul and then automatically be registered with a
    server that has the "loadbalancer" role

  * **but also** allow salt to install and configure services (like opensmtpd,
    dovecot, concourse.ci or a PHP application that can not be easily packaged
    in a .deb) and register that with consul to then make it available through
    a server that has the "loadbalancer" role

I generally, if in any way possible, would always prefer deploying an
application **not through salt states**, but other means (for example:
installing a .deb package on all servers that have the role "apps" through the
salt CLI client) or better yet, push Docker containers to Nomad / Kubernetes /
Docker Swarm. But if you have to (for example when configuring a service, which
is typically part of a Unix system like a mail server) you **totally can** use
salt states for that. This way you don't have to repackage services which are
already set up for your system. No need to repackage dovecot in a Docker
container, for example, if the Debian Maintainers do such an awesome job of
already providing ready-to-run packages anyway! (Also, repeat after me:
"Salt, Puppet, Chef and Ansible are not deployment tools!")

As I see it: use the best tool for the job. There is no dogma requiring you to
run all services inside a container for example. And a container is not a VM,
so services consisting of multiple daemons don't "containerize" easily anyway.
And some services really expect to use all available resources on a server
(databases, for example) and *shouldn't be containerized* for that reason. And so
on and so forth..... so use whatever feels natural. This salt setup is flexible
enough to accommodate all of these options.

## Deploying packaged services from .debs (GoPythonGo applications, for example)

## Deploying containerized services
Using servers with the `nomadserver` and `apps` roles, you have two options:

  1. Use Docker Swarm, which is built into Docker
  2. Use Hashicorp Nomad

They have different pros and cons, but Nomad supports scheduling jobs what are
not containerized (as in plain binaries and Java applications). Nomad also
directly integrates with Consul clusters *outside* of the Nomad cluster. So it
makes service discovery between applications living inside and outside of the
cluster painless. Using the smartstack implementation built into this
repository, you can just add `smartstack:*` tags to the `service {}` stanza in
your [Nomad job configuration](https://www.nomadproject.io/docs/job-specification/service.html)
and service discovery as well as linking services to the loadbalancer will be
taken care of.

For plain Docker or Docker Swarm, you will have to run a
[docker registrator](https://github.com/gliderlabs/registrator) instance on
each cluster node, which does the same job as including consul service
definitions in Nomad jobs. It registers services run from a docker container
with consul, discovering metadata from environment variables in the container.
Docker Swarm however, at least until Nomad 0.6 arrives, will have the benefit
of supporting VXLAN Overlay networks that can easily be configured to use
IPSEC encryption. This gives you a whole new primitive for separating logical
networks between your conainerized applications and is something to think
about.

Regardless of how the services get registered in Consul, it will in turn
propagate the service information through `consul-template` to `haproxy` making
the services accessible through localhost/docker-bridge based smartstack
routers, or even setting up routing to them from nodes with the `loadbalancer`
role, giving you fully automated service deployment for internal and external
services.


# SmartStack

See [consul-smartstack](https://github.com/jdelic/consul-smartstack).

### Integrating external services (not implemented yet)
**Question: But I run my service X on Heroku/Amazon Elastic Beanstalk with
autoscaling/Amazon Container Service/Microsoft Azure/Google Compute Engine/
whatever... how do I plug this into this smartstack implementation?**

**Answer:** You create a Salt state that registers these services as
`smartstack:internal` services, assign them a port in your [port map](PORTS.md)
and make sure haproxy instances can route to it.This will cause
`consul-template` instances on your machines to pick them up and make them
available on `localhost:[port]`. The ideal machines to assign these states to
in my opinion are all machines that have the `consulserver` role. Registering
services with consul that way can either be done by dropping service
definitions into `/etc/consul/services.d` or perhaps use
[use salt consul states](https://github.com/pravka/salt-consul).

A better idea security-wise is to create an "egress router" role that runs a
specialized version of haproxy-external that sends traffic from its internal IP
to your external services. Then announce the internal IP+Port as an internal
smartstack service. The external services can then still be registered with the
local Consul cluster, but you also have a defined exit point for traffic to
the external network.


# Vault

This salt configuration also runs an instance of
[Hashicorp Vault](https://vaultproject.io/) for better management of secure
credentials. It's good practice to integrate your applications with that
infrastructure.

Vault will be made available on `127.0.0.1` as an internal smartstack service
through haproxy via consul-template on port `8200` once it's been
initialized (depending on the backend) and
[unsealed](https://vaultproject.io/docs/concepts/seal.html).

Services, however, **must** access Vault through a local alias installed in
`/etc/hosts/` configured in the `allenvs.wellknown:vault:smartstack-hostname`
pillar (default: vault.local), because Vault requires SSL and that in turn
requires a valid SAN, so you have to configure Vault with a SSL certificate for
a valid hostname. I use my own CA and give Vault a certificate for the SAN
`vault.local` and then pin the CA certificate to my own CA's cert in the
`allenvs.wellknown:vault:pinned-ca-cert` pillar for added security (no other CA
can issue such a certificate for any uncompromised host).

## Backends
You can configure Vault through the `[hosting environment].vault` pillar to use
either the *consul*, *mysql*, *S3* or *PostgreSQL* backends.

### Vault database backend
Generally, if you run on multiple VMs sharing a physical server, choose the
`postgresql` backend and choose backup intervals and Vault credential leases
with a possible outage in mind. Such a persistent backend will not be highly
available, but unless you distribute your VMs across multiple physical
machines, your setup will not be HA anyway. So it's better to fail in a way 
that let's your restore service easily.

Running this setup from this Salt recipe requires at least one server in the
local environment to have the `database` role as it will host the Vault
PostgresSQL database. The Salt recipe will automatically set up a `vault`
database on the `database` role if the vault pillar has the backend
set  `postgresql`, because the `top.sls` file shipped from this repo assigns
the `vault.database` state to the `database` role.

To sum up: To enable this backend, set the Pillar
`[server environment].vault.backend` to `postgresql` and assign exactly one
server the `database` role (this salt configuration doesn't support database
replication) and at least one server the `vault` role.

[More information at the Vault website.](https://vaultproject.io/docs/config/index.html)

### Vault backend: consul
If you run your VMs in a Cloud or on multiple physical servers, running Vault
with the Consul cluster backend will offer high availability. In this case it
also makes sense to run at least two instances of Vault. Make sure to distribute
them across at least two servers though, otherwise a hardware failure might take
down the whole Consul cluster and thereby also erase all of the data.

[More information at the Vault website.](https://vaultproject.io/docs/config/index.html)


# Networking

## sysctl config
SysCTL is set up to accept

 * `net.ipv4.ip_forward` IPv4 forwarding so we can route packets to docker and
   other isolated separate networks
 * `net.ipv4.ip_nonlocal_bind` to allow local services to bind to IPs and ports
   even if those don't exist yet. This reduces usage of the `0.0.0.0` wildcard
   allowing to write more secure configurations.
 * `net.ipv4.conf.all.route_localnet` allows packets to and from `localhost` to
   pass through iptables, making it possible to route them. This is required so
   we can make consul services available on `localhost` even though consul runs 
   on its own `consul0` dummy interface.

## iptables states
iptables is configured by the `basics` and `iptables` states to use the
`connstate`/`conntrack` module to allow incoming and outgoing packets in the
`RELATED` state. So to enable new TCP services in the firewall on each
individual machine managed through this saltshaker, only the connection
creation needs to be managed in the machine's states.

The naming standard for states that enable ports that get contacted is:
`(servicename)-tcp-in(port)-recv`. For example:

```yaml
openssh-in22-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - proto: tcp
        - dport: 22
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables
```

The naming standard for states that enable ports that initiate connections is:
`(servicename)-tcp-out(port)-send`. For example:

```yaml
dns-tcp-out53-send:
      iptables.append:
          - table: filter
          - chain: OUTPUT
          - jump: ACCEPT
          - destination: '0/0'
          - dport: 53
          - match: state
          - connstate: NEW
          - proto: tcp
          - save: True
```

Connections *to* and *from* `localhost` are always allowed.

## Address overrides and standard interfaces
This saltshaker expects specific interfaces to be used for either internal or
external (internet-facing) networking. The interface names are assigned in the
`local|hetzner.network` pillar states in the `ifassign` states. Commonly the
network assignments are this:

  * `eth0` is either a local NAT interface (vagrant) or the lowest numbered
    full network interface.
  * The lowest numbered full network interface is commonly the "internal
    interface". It's connected to a non-routed local network between the nodes.
  * The next numbered full network interface is commonly the "external
    interface". It's connected to the internet.
  * The `consul0` interface is a dummy interface with a link-local IP of
    `169.254.1.1`. It's used to provide consul HTTP API and DNS API access to
    local services. A link-local address is used so it can be routed from
    the docker bridge.
  * `docker0` is the default bridge network set up by Docker that containers
    usually attach to.

Some configurations (like the mailserver states) can expect multiple external
network interfaces or at least multiple IP addresses to work correctly.

Therefor many states check a configuration pillar for themselves to figure out
whether they should bind to a specific IP and if not, use the first IP assigned
to the internal or external network interface. This is usually accomplished by
the following Jinja2 recipe:

```jinja2
{{
# first, check whether we have a configuration pillar for the service,
# otherwise return an empty dictionary
pillar.get('authserver', {}).get(
    # check whether the configuration pillar has a configuration option
    # 'bind-ip'. If not, return the first IP of the local internal interface
    'bind-ip',
    # query the machine's interfaces (ip_interfaces) and use the value returned
    # by the interface assiged to be internal in the ifassign pillar
    grains['ip_interfaces'][pillar['ifassign']['internal']][
        # use the first IP or the IP designated in the network pillar
        pillar['ifassign'].get('internal-ip-index', 0)|int()
    ]
)
}}
```

**Please note that commonly external services meant to be reached by the
internet listen to internal interfaces on their application servers and are
routed to the internet through the smartstack routing built into this
configuration.**.

## Reserved top-level domains

This configuration relies on three internal reserved domain suffixes, which
**must be replaced if they're ever brought up as a TLD on the global DNS**.
Those are:
  * `.local` which **must** resolve to an address in 127.0.0.1/24
  * `.internal` which **must** only be used within the non-publically-routed
    network (i.e. on an "internal" network interface)
  * `.consul.service` which is the suffix used by Consul for DNS based
    "service discovery" (repeat after me: *DNS is not a service discovery
    protocol*! Use Smartstack instead.)


# Configuration

## PostgreSQL

### Accumulators

**PostgreSQL**

The PostgreSQL configuration uses two accumulators that record `database user`
pairs (separated by a single space) for the `pg_hba.conf` file. These
accumulators are called:

  * `postgresql-hba-md5users-accumulator` and
  * `postgresql-hba-certusers-accumulator`

Each line appended to them creates a line in `pg_hba.conf` that is hardcoded
to start with `hostssl`, use the PostgreSQL server's internal network and
has the authentication method `md5` or `cert`. These accumulators are meant for
service configuration to automatically add login rights to the database after
creating database roles for the service.

The `filename` attribute for such `file.accumulated` states *must* be set to
`{{pillar['postgresql']['hbafile']}}` which is the configuration pillar
identifying the `pg_hba.conf` file for the installed version of PostgreSQL in
the default cluster. The accumulator must also have a `require_in` directive
tying it to the `postgresql-hba-config` state delivering the `pg_hba.conf` file
to the node.

Example:

```yaml
mydb-remote-user:
    file.accumulated:
        - name: postgresql-hba-md5users-accumulator
        - filename: {{pillar['postgresql']['hbafile']}}
        - text: {{pillar['vault']['postgres']['dbname']}} {{pillar['vault']['postgres']['dbuser']}}
        - require_in:
            - file: postgresql-hba-config
```

**Apache2**

The Apache2 configuration uses an acuumulator `apache2-listen-ports` to gather
all listen directives for its `/etc/apache2/ports.conf` file. The filename
attribute  for states setting up new `Listen` directives, should be set to 
`apache2-ports-config`. The values accumulated can be either just port numbers
or `ip:port` pairs.

Example:

```yaml
apache2-webdav-port:
    file.accumulated:
        - name: apache2-listen-ports
        - filename: /etc/apache2/ports.conf
        - text: {{my_ip}}:{{my_port}}
        - require_in:
            - file: apache2-ports-config
```

## PowerDNS Recursor

This Salt config sets up a PowerDNS recursor on every node that serves as an
interface to the Consul DNS API. It's usually only available to local clients
on `127.0.0.1:53` and `169.254.1.1:53` from where it forwards to Consul on 
`169.254.1.1:8600`. However, sometimes it's useful to expose the DNS API to
other services, for example on a Docker bridge or for other OCI containers.

### Accumulators

The PowerDNS configuration uses two accumulators to allow the adding of IPs
that PowerDNS Recursor listens on and allow CIDR ranges that can query the 
recursing DNS server on those IPs:

  * `powerdns-recursor-additional-listen-ips` and
  * `powerdns-recursor-additional-cidrs`
  
As above, the `filename` attribute for each `file.accumulated` state that uses
one such accumulator *must* be set to `/etc/powerdns/recursor.conf` and it must
have a `require_in` directive tying it to the `pdns-recursor-config` state.

Example:

```yaml
mynetwork-dns:
    file.accumulated:
          - name: powerdns-recursor-additional-listen-ips
          - filename: /etc/powerdns/recursor.conf
          - text: 10.0.254.1
          - require_in:
              - file: pdns-recursor-config
```


# Contributing

The following style is extraced from what has informally followed during
development of this repository and is therefor needed to remain consistent.

## General code style

  * Indents are 4 spaces
  * Top-level `yaml` elements have two newlines between them (just like Python
    PEP8)
  * Each file has a newline at the end of its last line
  * If you find yourself repeating the same states over and over (like creating
    an entry in `/etc/appconfig/` for each deployed application, write a custom
    Salt state (see `srv/_states/` for examples)
  * aside from MarkDown documentation, lines are up to 120 characters long
    unless linebreaks are impossible for technical reasons (long URLs,
    configuration files that don't support line breaks).
  * When breaking lines, search for "natural" points for well-readable line
    breaks. In natural language these usually are after punctuation. In code,
    they are usually found after parentheses in function calls or other code
    constructs, while indenting the next line, or at the end of statements.

### yaml code style

  * String values are in single quotes `'xyz'`
  * `.sls` yaml files should end with a vim modeline `# vim: syntax=yaml`.

### Documentation style
Use MarkDown formatted files.

  * formatted to 80 columns.
  * List markers are indented 2 spaces leading to a text indent of 4 (bullets)
    or 5 (numbers) on the first level.
  * Text starts right below a headline unless it's a first level headline *or*
    the paragraph starts off with a list.

## State structure

  * Jinja template files get the file extension `.jinja.[original extension]`
  * Configuration files should be stored near the states configuring the
    service
  * Only use explicit state ordering when in line with [ORDER.md}(ORDER.md).
  * Put states configuring services in the top-level `srv/salt/` folder then
    create a single state namespace with configuration for specific
    organizations (like the `mn` state).

## Pillar structure

  * Each state should get its configuration from a pillar.
  * Reuse configuration values through Jinja's
    `{% from 'file' import variable %}` since Salt does not support referencing
    pillars from pillars yet.
  * Use `{{salt['file.join'}(...)}}`, `{{salt['file.basename'}(...)}}`,
    `{{salt['file.dirname'}(...)}}` to construct paths from imported variables.
  * Pillars may import variables from things in `srv/pillars/shared/`,
    `srv/pillar/allenvs/` or from their local environment. No cross-environment
    imports.
  * Each deployment environment ("vagrant", "hetzner", "digialocean", "ec2" are
    all examples) get their own namespace in `srv/pillars/`.
  * Each environment has a special state called `*/wellknown.sls` that is
    assigned to *all* nodes in that environment for shared configuration values
    that can reasonably be expected to stay the same across all nodes, are not
    security critical and are needed or expected to be needed to run more than
    one service or application.
  * Pillars that are not security critical and are needed for multiple services
    or applications and can reasonably be expected to stay the same across all
    environments go into `allenvs.wellknown`.
  * `srv/pillar/shared/` is the namespace for configuration that is shared
    across environments (or can reasonably expected to be the same, so that it
    makes sense to only override specific values in the pillars for a specific
    environment), *but* is not assigned to all nodes because its contents may
    be security critical or simply only needed on a single role.

### SSL configuration in Pillars
SSL configuration should use the well-known keys `sslcert`, `sslkey` and if
supported, clients should have access to a `pinned-ca-cert` pillar so the CA
can be verified. `sslcert` and `sslkey` should support the magic value
`default` which should make the states render configuration files referring to
the pillars `ssl:default-cert(-combined)` and `ssl:default-cert-key`.
