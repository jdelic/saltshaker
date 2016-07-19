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

    # leading "not" is not supported http://docs.saltstack.com/en/latest/topics/targeting/compound.html
    # everything that is not a consul server has a consul agent
    '* and not G@roles:consulserver':
        - match: compound
        - consul.agent

    'roles:consulserver':
        - match: grain
        - consul.server

    'G@roles:secure-database or G@roles:mail':
        - match: compound
        - fstab.secure

    'roles:master':
        - match: grain
        - compilers
        - djb
        - djb.daemontools
        - djb.ucspitcp
        - djb.dns
        - salt-master
# this needs network interface config
#        - djb.dns.services

    'roles:vault':
        - match: grain
        - vault

    'roles:dev':
        - match: grain
        - apache
        - dev.pbuilder
        - dev.aptly
        - dev.fpm
        - dev.concourse.server
        - dev.concourse.worker
#        - dev.pypi
#        - sentry
        - compilers
        - python.dev
        - docker

    'roles:apps':
        - match: grain
        - apache
        - php
        - djb.daemontools
        - mn.services
        - docker

    'roles:servicerunner':
        - mn.services

    'roles:database':
        - match: grain
        - fstab.data
        - postgresql.fast
        - redis.cache

    'roles:secure-database':
        - match: grain
        - postgresql.secure
        - vault.mysql_database  # this state is empty if vault uses a different backend than "mysql"

    'roles:mail':
        - match: grain
        - compilers
        - dovecot
        - mn.cas.client  # only use with casserver, otherwise comment out
        - fstab.mailqueue

    'roles:pim':
        - match: grain
        - sogo

    'roles:casserver':
        - match: grain
        - mn.cas.server

    'roles:loadbalancer':
        - match: grain
        - haproxy.external

    '*.test':
        # put vagrant user config on .test machines
        - mn.users.vagrant
        # enable the NAT networking device for all network traffic
        - iptables.vagrant

# put my personal user on every other machine
    '(?!saltmaster).*?net(|.internal)$':
        - match: pcre
        - mn.users.jonas
