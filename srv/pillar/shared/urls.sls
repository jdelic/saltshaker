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
    concourse: https://github.com/concourse/concourse/releases/download/v6.7.2/concourse-6.7.2-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v6.7.2/fly-6.7.2-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.9.0/consul_1.9.0_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.5.0/consul-esm_0.5.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.25.1/consul-template_0.25.1_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/1.0.0/nomad_1.0.0_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.1.1/nomad-autoscaler_0.1.1_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.14.2/terraform_0.14.2_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.3.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.0/vault-ssh-helper_0.2.0_linux_amd64.zip


hashes:
    concourse: sha256=a93af5d03b649cc8d84333568a349876f299cb58f4383981338262022a1ff068
    concourse-fly: sha256=974ec56d3b43e7ef77fa8fc43b0652a308b39e8d860191f861812e7111af20bc
    consul: sha256=409b964f9cec93ba4aa3f767fe3a57e14160d86ffab63c3697d188ba29d247ce
    consul-esm: sha256=96dae821bd3d1775048c9dbe8d6112ed645c9b912786c167ba9417f59509059d
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=58356ec125c85b9705dc7734ed4be8491bb4152d8a816fd0807aed5fbb128a7b
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=24102aa16e82330fac7de3b8156eb10d7ef535027c4d33321e7e64d6049442a4
    nomad-autoscaler: sha256=4e3fcd16ad1dc8fad3d66b76c452649a4e4dc53ce9d95e541aa04518479396c4
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=6f380c0c7a846f9e0aedb98a2073d2cbd7d1e2dc0e070273f9325f1b69e668b2
    vault: sha256=83048e2d1ebfea212fead42e474e947c3a3bccc5056a5158ed33f530f8325e39
    vault-gpg-plugin: sha256=eee08f28f4be8889fefa097b45819eca857d374ee856d3cd803207ede0c559d3
    vault-ssh-helper: sha256=a88825a0cbf47aab9a8166930b4c7cb9dcfdc7b335fdcc2b2966b1baf5e251bf
