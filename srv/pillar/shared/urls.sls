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
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://packages.broadcom.com/artifactory/saltproject-deb/ stable main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.0.7.zip
    concourse: https://github.com/concourse/concourse/releases/download/v7.12.0/concourse-7.12.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.12.0/fly-7.12.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.20.1/consul_1.20.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.8.0/consul-esm_0.8.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.39.1/consul-template_0.39.1_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.9.3/nomad_1.9.3_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.5/nomad-autoscaler_0.4.5_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.2.0/nomad-pack_0.2.0_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.18.1/vault_1.18.1_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=c2061e70cc8ee42a9a209a7c76ce6565fff7373cd59619b34846bfb435596230
    concourse: sha256=aee4e8553a7fbd9f418c639a6bee25e39fe46061fa1410cd720c92aa74692769
    concourse-fly: sha256=de1865c3707066f7f18da2b4272e1ecbe0042d29f02e87844168b71d952fa484
    consul: sha256=d38e7571177909d437a9cbcc62fb65083bc567266b74a62d02c6abe783951648
    consul-esm: sha256=8ad873fdee0b38b5b51830b5218b04d3fe60ee47dc1d6993ce431d5ed91f223c
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=b77c7550defda78c62b036c734e7faceb7f89519dc12406db84f2c3af06bc5fb
    nomad: sha256=517bce4fcebdc71335ac33a1e34a4c262d2417d8ed4e60cf895fc59e69d70c84
    nomad-autoscaler: sha256=7fe0fa32a46688b4344e9a0acea380f0119c1dd2a11ef980acdbe674b959b110
    nomad-pack: sha256=32533e635b78101056f411366e26aca7778ea80f8556002f825784e1d75a4437
    terraform: sha256=9cf727b4d6bd2d4d2908f08bd282f9e4809d6c3071c3b8ebe53558bee6dc913b
    vault: sha256=d6486e4644cbeefa841ff6a41e39b68a5129c329bd2e271b29368948ff9ddfc4
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
