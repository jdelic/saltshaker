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
    concourse: https://github.com/concourse/concourse/releases/download/v7.11.2/concourse-7.11.2-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.11.2/fly-7.11.2-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.19.2/consul_1.19.2_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.7.2/consul-esm_0.7.2_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.39.1/consul-template_0.39.1_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.8.3/nomad_1.8.3_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.5/nomad-autoscaler_0.4.5_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.1.2/nomad-pack_0.1.2_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.17.5/vault_1.17.5_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=c2061e70cc8ee42a9a209a7c76ce6565fff7373cd59619b34846bfb435596230
    concourse: sha256=9de8cf177372e6afa907700c2ae5f943c9e7ac258aea6afbc6b0fe3ec728d985
    concourse-fly: sha256=0a318fe9df56d8299a8abd863aeb4e1e9632e6c91da92abef19984bd1910d8e2
    consul: sha256=9315d95b19cf851f8fb0013b583ede6f61d591a9024a7dbb9b37eee45270abd2
    consul-esm: sha256=c6ad998ac5599eacddc54800355c39d289e486f5a61e3d92a5580895e4e8bdd5
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=b77c7550defda78c62b036c734e7faceb7f89519dc12406db84f2c3af06bc5fb
    nomad: sha256=a0c92d427fe8839bf3aab9c62b2d12190483f953a3483c08891e53f65f676797
    nomad-autoscaler: sha256=7fe0fa32a46688b4344e9a0acea380f0119c1dd2a11ef980acdbe674b959b110
    nomad-pack: sha256=7b89d9652e8622a99270fbbbc7fb457383d9f624faceaa41d2292bacd37a51ae
    terraform: sha256=9cf727b4d6bd2d4d2908f08bd282f9e4809d6c3071c3b8ebe53558bee6dc913b
    vault: sha256=67eb9f95d37975e2525bbd455e19528a7759f3a56022de064bf8605fc220be47
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
