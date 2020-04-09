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
    haproxy: deb http://haproxy.debian.net buster-backports-2.1 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/buster/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/buster/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v6.0.0/concourse-6.0.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v6.0.0/fly-6.0.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.7.2/consul_1.7.2_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.3.3/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.23.0/consul-template_0.23.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.11.0/nomad_0.11.0_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.4.0/vault_1.4.0_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.2.4/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.4/vault-ssh-helper_0.1.4_linux_amd64.zip


hashes:
    concourse: sha256=2bb10ccaed94897089e1bde764c6c1e0ee4820a9ccd2f7600be25646f271f7b0
    concourse-fly: sha256=be12ddd8e01ebf906b76d272fe57da491f77c1327f7f92b5f6abd298cad4d43f
    consul: sha256=5ab689cad175c08a226a5c41d16392bc7dd30ceaaf90788411542a756773e698
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=8f7fa4492d29930f4d621b8643d734cb3f4318c32cc088f7c68519ccd9f6f33f
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=cd76c59af28757ee916811baf92c2ea8daa9125052f76ebb21daf5e10ef2db21
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11
    vault: sha256=8f739c4850bab35e971e27c8120908f48f247b07717d19aabad1110e9966cded
    vault-gpg-plugin: sha256=d6ebf6457a7ccf3294c557d4b33b7ded66d74feb761e3e056ddced1fdaed4fba
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
