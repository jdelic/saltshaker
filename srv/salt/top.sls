#
# maurus.net salt states
#

base:
    '*':
        - basics
        - byobu
        - mn.users
        - roles
        - consul.template  # everything needs consul-template in smartstack
        - haproxy.internal  # everything needs local proxies in smartstack
        - powerdns.recursor
        - duplicity
        - vault.install
        - mn.cas.client

    'roles:xenserver':
        - match: grain
        - xen
        - consul.server

    # everything that is not a consul server has a consul agent
    'not G@roles:consulserver and not G@roles:xenserver':
        - match: compound
        - consul.agent

    'roles:consulserver':
        - match: grain
        - consul.server

    'roles:master':
        - match: grain
        - compilers
        - salt-master

    'roles:vault':
        - match: grain
        - vault
        - mn.cas.vault_database
        - dev.concourse.vault_credentials

    'roles:docker-registry':
        - match: grain
        - docker.registry

    'roles:dev':
        - match: grain
        - dev.pbuilder
        - dev.aptly.install
        - dev.aptly.apiserver
        - dev.fpm
#        - dev.pypi
#        - sentry
        - compilers
        - python.dev
        - docker.install

    'roles:buildserver':
        - match: grain
        - vault.install
        - dev.concourse.server

    'roles:buildworker':
        - match: grain
        - dev.concourse.worker
        - vault.install
        - nomad.client

    'roles:apps':
        - match: grain
        - docker.install
        - nomad.install
        - mn.appconfig

    'roles:photosync':
        - match: grain
        - mn.photosync
        - fstab.secure

    'roles:database':
        - match: grain
        - fstab.secure
        - fstab.data
        - postgresql.fast
        - postgresql.checkuser
        - redis.cache
        - dev.concourse.postgres_database
        - postgresql.secure
        - vault.database  # this state is empty if vault doesn't use a database backend
        - vault.postgres_admin  # gives Vault admin rights for using the postgresql Vault secret backend
        - mn.cas.postgres_database # this state is empty if authserver doesn't use a database backend
        - mn.cas.postgres_spapi_access # ^ ditto

    # every node that's not a mailserver routes through a mailserver via smartstack
    'not G@roles:mail':
        - match: compound
        - ssmtp

    'roles:mail':
        - match: grain
        - fstab.secure
        - dovecot
        - opensmtpd.install
        - mail.spamassassin
        - mail.storage
        - mn.cas.dkimsigner
        - mn.cas.mailforwarder
        - ssmtp.not

    'roles:pim':
        - match: grain
        - fstab.secure
        - radicale

    'roles:authserver':
        - match: grain
        - mn.cas.server
        - mn.appconfig
        - docker.authserver_dockerregistry  # empty unless a JWT key is configured
        - apache.webdav_permissions_py
        - dev.concourse.authserver_oauth2

    'roles:loadbalancer':
        - match: grain
        - haproxy.external

    'roles:vpngateway':
        - match: grain
        - openvpn.gateway

    'not G@roles:vpngateway':
        - match: compound
        - openvpn.gateway_accessible

    'roles:webdav':
        - match: grain
        - apache.webdav

    '*.test':
        # put vagrant user config on .test machines
        - mn.users.vagrant
        # enable the NAT networking device for all network traffic
        - iptables.vagrant

    # put my personal user on every other machine
    '(?!saltmaster).*?net(|.internal)$':
        - match: pcre
        - mn.users.jonas
