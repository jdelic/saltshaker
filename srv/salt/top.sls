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

    'roles:xenserver':
        - match: grain
        - xen
        - consul.server

    # leading "not" is not supported http://docs.saltstack.com/en/latest/topics/targeting/compound.html
    # everything that is not a consul server has a consul agent
    '* and not G@roles:consulserver and not G@roles:xenserver':
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
        - vault.vault_goldfish
        - dev.concourse.vault_credentials

    'roles:goldfish':
        - match: grain
        - vault.goldfish_ui

    'roles:docker-registry':
        - match: grain
        - docker.registry

    'roles:dev':
        - match: grain
        - dev.pbuilder
        - dev.aptly
        - dev.fpm
#        - dev.pypi
#        - sentry
        - compilers
        - python.dev
        - docker

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
        - docker
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
    '* and not G@roles:mail':
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

    'roles:loadbalancer':
        - match: grain
        - haproxy.external

    'roles:vpngateway':
        - match: grain
        - openvpn.gateway

    '*.test':
        # put vagrant user config on .test machines
        - mn.users.vagrant
        # enable the NAT networking device for all network traffic
        - iptables.vagrant

    # put my personal user on every other machine
    '(?!saltmaster).*?net(|.internal)$':
        - match: pcre
        - mn.users.jonas
