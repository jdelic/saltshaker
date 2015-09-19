# jdelic's Saltshaker

This is a collection of saltstack formulae designed to bring up an small
hosting environment for multiple applications and services. The hosting
environment is reusable, the services are primarily there to fulfill my needs.

Cloning this repository is a good basis for your own Salt setup as it
implements a number of best practices I discovered and includes a fully
fledged [SmartStack](http://nerds.airbnb.com/smartstack-service-discovery-cloud/)
implementation for internal, external and cross-datacenter services.

It also builds on the principles I have documented in my
[GoPythonGo](http://gopythongo.com) build and deployment process.

It has full support for [Vagrant](http://vagrantup.com/), allowing easy
testing of new functionality and different setups on your local machine before
deploying them. Personally, I'm deploying this configuration on my laptop
using Vagrant, on Digital Ocean and my own server on Hetzner which I configure
with a XEN Hypervisor running VMs for all my development needs.

Everything in here is based around **Debian 8.0 Jessie** (i.e. requires
systemd and uses Debian package naming).

Using these salt formulae you can bring up:

  * a primarily Python/Django based application environment

  * including a consul/consul-template based
    [smartstack](http://nerds.airbnb.com/smartstack-service-discovery-cloud/)
    implementation for service discovery

  * a MySQL database configuration for a normal and an encrypted database

  * a Jenkins build server environment for [GoPythonGo](http://gopythongo.com)
    based builds and deployment

  * an HAProxy based HTTP reverse proxying load balancer for applications

  * Apache2+php-fpm for my WordPress blog

It also contains configuration for

  * a fully fledged PIM+Mail server with encrypted storage (based on
    [Sogo](http://sogo.nu), [Dovecot](http://dovecot.org) and
    [Qmail](http://cr.yp.to/qmail.html) (with
    [John Simpson's combined patch](http://qmail.jms1.net/)))

  * single-sign-on for Sogo, Dovecot and Qmail, other web applications and even
    PAM using CAS

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
     git clone https://bitbucket.org/jdelic/saltshaker
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
     environment).

  6. Run `salt-call state.highstate -l debug` on your master to bring it up.

  7. Bring up additional nodes (at least the count of consul server instances)

  8. Assign them roles, install the salt minion using `install_salt.sh -P` and
     call state.highstate. It's obviously much better to *automate* this step.
     I did so for the XEN Hypervisor for example using the scripts in `role.d`
     together with `xen-create-image`.


# Server configuration

## Networking

### Pillar overrides

## Disks

### /secure


## The roledir grain


## Available roles


# Salt modules


## The dynamicpasswords pillar

# Deploying applications

## Service deployment "through" salt and "on" servers configured by salt

First off, don't get confused by the service configuration and discovery states
that seem to be "interwoven" in this repository. The whole setup is meant to

  * allow applications to be deployed from .debs or Docker containers, being
    discovered through consul and then automatically be registered with a
    server that has the "loadbalancer" role

  * **but also** allow salt to install and configure services (like qmail,
    dovecot or a PHP application that can not be easily packaged in a .deb)
    and register that with consul to then make it available through a server
    that has the "loadbalancer" role

I generally, if in any way possible, would always prefer deploying an
application not through salt states, but other means (for example: installing
a .deb package on all servers that have the role "apps" through the salt CLI
client), but if you have to (for example when configuring a service typically
part of a Unix system like a mail server) you **totally can** use salt states
for that. This way you don't have to repackage services which are already set
up for your system. No need to repackage dovecot in a Docker container, for
example, if the Debian Maintainers do such an awesome job of already providing
ready-to-run packages anyway!

As I see it, use the best tool for the job. There is no dogma requiring you to
run all services inside a container for example. And a container is not a VM,
so services consisting of multiple daemons don't "containerize" easily anyway.
And some services really expect use all available resources on a server
(databases, for example) and shouldn't be containerized for that reason. And so
on and so forth..... so use whatever feels natural. This salt setup is flexible
enough to accommodate all of these options.

## Deploying packaged services from .debs (GoPythonGo applications, for example)

## Deploying containerized services
Easy: every application server runs a
[docker registrator](https://github.com/gliderlabs/registrator) instance which
does the same job as including consul service definitions with your deployable
releases. It registers services run from docker container with consul,
discovering metadata from environment variables in the container. Consul in
turn will propagate the service information through `consul-template` to
`haproxy` making the services accessible or even routing them from servers with
the `loadbalancer` role.

# SmartStack

## Taga

Tag                            | Description
-------------------------------|-----------------------------------------------
smartstack:internal            | Route through haproxy on localhost
smartstack:external            | Route through haproxy on loadbalancers (role)
smartstack:cross-datacenter    | Route through haproxy on localhost remotely
smartstack:port:[port]         | Route through haproxy on port [port]
smartstack:hostname:[hostname] | Route through haproxy on HTTP Host header


## Integrating SmartStack with remote services

### Cross-datacenter services between two salt-controlled environments
TODO: smartstack:cross-datacenter

### Integrating external services
**Question: But I run my service X on Heroku/Amazon Elastic Beanstalk with
autoscaling/Amazon Container Service/Microsoft Azure/Google Compute Engine/
whatever... how do I plug this into this smartstack implementation?**

**Answer:** You create a Salt state that registers these services as
*cross-datacenter internal* services using the tag `smartstack:cross-datacenter`
and assign them a port in your [port map](PORTS.md). This will cause
`consul-template` instances on your machines to pick them up and make them
available on `localhost:[port]`. The ideal machines to assign these states to
in my opinion are all machines that have the `consulserver` role. Registering
services with consul that way can either be done by dropping service
definitions into `/etc/consul/services.d`, which might lead to strange behavior
if different versions end up on multiple machines or better
[use salt consul states](https://github.com/pravka/salt-consul).

# Vault

This salt configuration also runs an instance of
[Hashicorp Vault](https://vaultproject.io/) for better management of secure
credentials. It's good practice to integrate your applications with that
infrastructure.

Vault will be made available on `localhost` as an internal smartstack service
through haproxy via consul-template on port # TODO: PORT once it's been
initialized (depending on the backend) and
[unsealed](https://vaultproject.io/docs/concepts/seal.html).

## Backends
You can configure Vault through the `[hosting environment].vault` pillar to use
either the *consul* or *mysql* backend.

### Vault backend: mysql
Generally, if you run on multiple VMs sharing a physical server, choose the
`mysql` backend and choose backup intervals and Vault credential leases with
a possible outage in mind. Such a persistent backend will not be highly
available, but unless you distribute your VMs across multiple physical
machines, your setup will not be HA anyway. So it's better to fail in a way
that let's your restore service easily.

Running this setup from this Salt recipe requires at least one server in the
local environment to have the `secure-database` role as it will host the
Vault MySQL database. The Salt recipe will automatically set up a `vault`
database on the `secure-database` role if the vault pillar has the backend
set to "mysql".

To enable this backend, set the Pillar `[server environment].vault.backend` to
`mysql` and assign one server the role `secure-database` (this salt
configuration doesn't support database replication) and at least one server the
`vault` role.

[More information at the Vault website.](https://vaultproject.io/docs/config/index.html)

### Vault backend: consul
If you run your VMs in a Cloud or on multiple physical servers, running Vault
with the Consul cluster backend will offer high availability. In this case it
also makes sense to run at least two instances of Vault. Make sure to distribute
them across at least two servers though, otherwise a hardware failure might take
down the whole Consul cluster and thereby also erase all of the data.

[More information at the Vault website.](https://vaultproject.io/docs/config/index.html)
