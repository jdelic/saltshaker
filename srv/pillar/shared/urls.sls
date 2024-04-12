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
    consul: https://releases.hashicorp.com/consul/1.18.1/consul_1.18.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.7.1/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.37.4/consul-template_0.37.4_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.7.6/nomad_1.7.6_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.3/nomad-autoscaler_0.4.3_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.1.0/nomad-pack_0.1.0_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_386.zip
    vault: https://releases.hashicorp.com/vault/1.16.1/vault_1.16.1_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=fa48ad44c6973e6537e54f9e586f1d9ccb14526b216c3788eaee3290b07df0be
    concourse-fly: sha256=7ac3fda96ae193bee95f92fdbc9decfc563cd14393882e47520ab67fa1a075f5
    consul: sha256=5faa9cc3f2832e3ae454a3ec2dbc6799179d14e1e09463f220bb906c590f4b05
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=f43567923e57f1e8ad30b07a3bc0a303b7213d13a5ad5c1ed7b3a9ea09be8275
    nomad: sha256=82a438a144066a8f42ceea8548da754c0bd96b5b528cd337a5dc09017afddb56
    nomad-autoscaler: sha256=c66e352accca50413202f88144e5aa2211c185f6a58a1061df38c42753f0f0a0
    nomad-pack: sha256=20604ae26caffc506a5f6ad993bc8925f6022d1875c678e91a0897e1a2411288
    terraform: sha256=858e2ca2d38ce3644607af68eb5184a91493feecf82346deb386fd6cfbfad785
    vault: sha256=315a1964d7003ef6de94c407a88972d45eb9b378946a53a1bbff34de1ae2d1e0
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
