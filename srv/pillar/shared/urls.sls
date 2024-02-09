# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/aptly-archive.gpg arch=amd64] http://repo.aptly.info/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/aptly-nightly-archive.gpg arch=amd64] http://repo.aptly.info/ nightly main
    bookworm: deb http://ftp-stud.hs-esslingen.de/debian/ bookworm main contrib
    bookworm-backports: deb http://ftp-stud.hs-esslingen.de/debian/ bookworm-backports main
    bookworm-security: deb http://security.debian.org/debian-security bookworm-security main
    bookworm-updates: deb http://deb.debian.org/debian bookworm-updates main
    docker: deb [signed-by=/etc/apt/keyrings/docker-archive.gpg arch=amd64] https://download.docker.com/linux/debian bookworm stable
    haproxy: deb [signed-by=/etc/apt/keyrings/haproxy.debian.net.gpg arch=amd64] http://haproxy.debian.net bookworm-backports-2.8 main
    maurusnet-apps: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/nightly/bookworm/ mn-nightly main
    maurusnet-opensmtpd: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/bookworm/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/bookworm/radicale/ mn-radicale main
    postgresql: deb [signed-by=/etc/apt/keyrings/postgresql-archive.gpg arch=amd64] http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/minor/3006.4 bullseye main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.0.4.zip
    concourse: https://github.com/concourse/concourse/releases/download/v7.11.1/concourse-7.11.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.11.1/fly-7.11.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.17.2/consul_1.17.2_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.7.1/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.36.0/consul-template_0.36.0_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.7.3/nomad_1.7.3_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.1/nomad-autoscaler_0.4.1_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview.3/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.7.1/terraform_1.7.1_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.15.4/vault_1.15.4_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=fa48ad44c6973e6537e54f9e586f1d9ccb14526b216c3788eaee3290b07df0be
    concourse-fly: sha256=7ac3fda96ae193bee95f92fdbc9decfc563cd14393882e47520ab67fa1a075f5
    consul: sha256=e16489849b3b203251d93fef94d60600b59cb776c11b66959786e3484d336381
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=9844aebb997b81dd5b58a6ddadbf650eca4b200ccbc2ad680d817528a73c0d3a
    nomad: sha256=ee0d93fe1b2d5aead6bc5c0508c8ac99822e11157c0e1172f5da0d7d139c26c8
    nomad-autoscaler: sha256=fdad9f030a80c485b6891fd95b685d23d2d546f1bfa7f0c0beae615765ed5abf
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=64ea53ae52a7e199bd6f647c31613ea4ef18f58116389051b4a34a29fb04624a
    vault: sha256=f42f550713e87cceef2f29a4e2b754491697475e3d26c0c5616314e40edd8e1b
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
