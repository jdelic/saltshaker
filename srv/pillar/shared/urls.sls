# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    buster: deb http://ftp-stud.hs-esslingen.de/debian/ buster main contrib
    buster-backports: deb http://ftp-stud.hs-esslingen.de/debian/ buster-backports main
    buster-security: deb http://security.debian.org/debian-security buster/updates main
    buster-updates: deb http://ftp-stud.hs-esslingen.de/debian/ buster-updates main
    docker: deb https://download.docker.com/linux/debian buster stable
    envoy: deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb buster stable
    haproxy: deb http://haproxy.debian.net buster-backports-2.2 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/buster/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/buster/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v7.3.1/concourse-7.3.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.3.1/fly-7.3.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.9.6/consul_1.9.6_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.5.0/consul-esm_0.5.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.25.1/consul-template_0.25.1_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/1.1.0/nomad_1.1.0_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.3/nomad-autoscaler_0.3.3_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.7.2/vault_1.7.2_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.3.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    concourse: sha256=085e20ef24bad0f40d35a6b8b86bf36c8c074ca1fe209febf745fe025b894184
    concourse-fly: sha256=7667e48e38ff97cf0a7ae0a9038c2cbc7eda5f2cbbd9e2868768e7b0bfefd7de
    consul: sha256=f999955f135b3170108a0d1b7ca69a60dc80769e0b039f32f551fc8032d25f4b
    consul-esm: sha256=96dae821bd3d1775048c9dbe8d6112ed645c9b912786c167ba9417f59509059d
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=58356ec125c85b9705dc7734ed4be8491bb4152d8a816fd0807aed5fbb128a7b
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=7c3b35520fc05e4aad49663564a852448f52ad58e3261040c9df2f6a44716736
    nomad-autoscaler: sha256=8d4f1fbcf93cf637e042f3dcd8894f8653f501cfb5de6978481b961c8a4ddfa4
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=8be33cc3be8089019d95eb8f546f35d41926e7c1e5deff15792e969dde573eb5
    vault: sha256=5ee6bb8119b55c27cd3864c982177714a0a4a3813927ccafdb262e78e4bb67bc
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=eee08f28f4be8889fefa097b45819eca857d374ee856d3cd803207ede0c559d3
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
