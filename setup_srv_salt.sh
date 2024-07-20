#!/usr/bin/env bash

# This is a quick helper script to set up /srv/salt correctly from
# a git clone at /srv/saltshaker.

if test ! -d /srv/saltshaker; then
    echo "First clone /srv/saltshaker"
    exit 1;
fi

pushd /srv/saltshaker
git submodule init
git submodule update
if [ ! -e /srv/salt ]; then
    ln -sv /srv/saltshaker/srv/salt /srv/salt
fi
if [ ! -e /srv/salt-modules ]; then
    ln -sv /srv/saltshaker/srv/salt-modules /srv/salt-modules
fi
if [ ! -e /srv/pillar ]; then
    ln -sv /srv/saltshaker/srv/pillar /srv/pillar
fi
if [ ! -e /srv/reactor ]; then
    ln -sv /srv/saltshaker/srv/reactor /srv/reactor
fi
chown -R salt:salt /etc/salt
salt-call saltutil.sync_all
systemctl restart salt-master
popd
