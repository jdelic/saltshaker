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
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.0.4.zip
    concourse: https://github.com/concourse/concourse/releases/download/v7.11.0/concourse-7.11.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.11.0/fly-7.11.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.17.0/consul_1.17.0_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.7.1/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.35.0/consul-template_0.35.0_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.6.3/nomad_1.6.3_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.7/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview.3/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.6.3/terraform_1.6.3_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.15.2/vault_1.15.2_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=ef75c157c15b4672e432ab6eea8cbc0d6db600747a0f0ec0f3c6536c9ff8eb25
    concourse-fly: sha256=c49a654eadbdf190799393fa03fe264ccb41302153e3b6208f32de5092334f57
    consul: sha256=4fbb6c3a05ddfc72d314149fe9765a1be89c33857b003a1d861469f2fe97e23e
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=1b1c9127e8da25b2d7322e6f2aa8e6d946336083999e0fdb321f96ffd447eebd
    nomad: sha256=1771f83030d9c0e25b4b97b73e824f4b566721e3b9898ae9940eceb95bb7f4d0
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=caa432f110db519bf9b7c84df23ead398e59b6cc3da2938f010200f1ee8f2ae4
    vault: sha256=5a0820943bc212713ba57a5136b5ec96dd1a6fc5a1c61666407d996027b2e694
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
