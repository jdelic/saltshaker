# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/aptly-archive.gpg arch=amd64] http://repo.aptly.info/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/aptly-nightly-archive.gpg arch=amd64] http://repo.aptly.info/ nightly main
    docker: deb [signed-by=/etc/apt/keyrings/docker-archive.gpg arch=amd64] https://download.docker.com/linux/debian trixie stable
    haproxy: deb [signed-by=/etc/apt/keyrings/haproxy-archive-keyring.gpg arch=amd64] http://haproxy.debian.net trixie-backports-3.2 main
    maurusnet: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/nightly/trixie mn-nightly main
    postgresql: deb [signed-by=/etc/apt/keyrings/postgresql-archive.gpg arch=amd64] http://apt.postgresql.org/pub/repos/apt/ trixie-pgdg main
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://packages.broadcom.com/artifactory/saltproject-deb/ stable main
    trixie: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://ftp-stud.hs-esslingen.de/debian/ trixie main contrib
    trixie-backports: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://ftp-stud.hs-esslingen.de/debian/ trixie-backports main
    trixie-security: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://security.debian.org/debian-security trixie-security main
    trixie-updates: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://deb.debian.org/debian trixie-updates main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.1.0.zip
    concourse: https://github.com/concourse/concourse/releases/download/v7.12.1/concourse-7.12.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.12.1/fly-7.12.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.21.4/consul_1.21.4_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.9.0/consul-esm_0.9.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.41.1/consul-template_0.41.1_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.10.4/nomad_1.10.4_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.7/nomad-autoscaler_0.4.7_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.4.0/nomad-pack_0.4.0_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.20.2/vault_1.20.2_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=1e00a4d2df81ded9987840671ad5b5c75f17ac0f2f6f87c647b7051e71a13de3
    concourse: sha256=669131180f1b3d9e30b32fd139586acbca4d762386ea481055736d6361499d43
    concourse-fly: sha256=dd1e5f94214632a09ce07426c2392ab8803ae8b307c0ba5436239e9b67d01c52
    consul: sha256=a641502dc2bd28e1ed72d3d48a0e8b98c83104d827cf33bee2aed198c0b849df
    consul-esm: sha256=9ed3a3381d451fef8ed2067dec9887962ebb92702650d43a8c85ca3c706372ea
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=ab68e09642437dcc5b6e9a572a1924d3969e4fe131f50a1a3a4f782d7a21f530
    nomad: sha256=33f50ef9a56ceb995768a1301c7bc73d9270fd751378de5b3cffcf21af9112a2
    nomad-autoscaler: sha256=9d0b8164a30d9b98ad87355ccc6ed2855cd99452e96eea3e13c0dc9a1cbf2e56
    nomad-pack: sha256=c4597c3bfa31f3f3296584dc7fc63f92c8ad35b92b85f9df75ec4c405ac082c0
    terraform: sha256=1eaed12ca41fcfe094da3d76a7e9aa0639ad3409c43be0103ee9f5a1ff4b7437
    vault: sha256=5846abf08deaf04cc9fdbb7c1eddda3348671590445f81bcdb0a2e0d32396c2e
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
