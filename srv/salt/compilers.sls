
# build environment

build-essential:
    pkg.installed

make:
    pkg.installed

libssl-dev:
    pkg.installed:
        - fromrepo: jessie-backports
