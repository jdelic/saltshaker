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
    envoy: deb [arch=amd64] https://deb.dl.getenvoy.io/public/deb/debian buster main
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
    concourse: https://github.com/concourse/concourse/releases/download/v7.3.2/concourse-7.3.2-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.3.2/fly-7.3.2-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.10.1/consul_1.10.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.5.0/consul-esm_0.5.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.26.0/consul-template_0.26.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/1.1.2/nomad_1.1.2_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.3/nomad-autoscaler_0.3.3_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.7.3/vault_1.7.3_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.3.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    concourse: sha256=73ab38fc8ab1db6dbc059465cda7cae3927fdff8f32eb4d5bdde17fbb48ea481
    concourse-fly: sha256=919f79a0c2c94b38738440a1bb9c0dfeb3b2bd126602a2a13e3d12b4830b8a5a
    consul: sha256=abd9a7696e2eeed66fdb28965c220a2ba45ee5cd79ff263557f5392291aab730
    consul-esm: sha256=96dae821bd3d1775048c9dbe8d6112ed645c9b912786c167ba9417f59509059d
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=d4b1d8dc46289a4bdbb73301cd1dbdd9b41eddcab4103f006c5bf9637f7e4381
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=fa25e3353db520ac94b1a28c0b08a9ceb35c807c35987ae21910a41c179730d0
    nomad-autoscaler: sha256=8d4f1fbcf93cf637e042f3dcd8894f8653f501cfb5de6978481b961c8a4ddfa4
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=7329f887cc5a5bda4bedaec59c439a4af7ea0465f83e3c1b0f4d04951e1181f4
    vault: sha256=8453132a93b755c0a89dd4b2f1a99bd4af06f8167b81917f117080839031e03f
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=eee08f28f4be8889fefa097b45819eca857d374ee856d3cd803207ede0c559d3
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
