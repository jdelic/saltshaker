# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    buster: deb http://fileserver.maurusnet.test/debian/ buster main
    buster-backports: deb http://fileserver.maurusnet.test/debian/ buster-backports main
    buster-security: deb http://fileserver.maurusnet.test/debian/security/ buster-updates main
    buster-updates: deb http://fileserver.maurusnet.test/debian/ buster-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ buster stable
    envoy: deb [arch=amd64] http://fileserver.maurusnet.test/getenvoy-deb/ buster stable
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ buster-backports-2.2 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ buster-pgdg
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/10/amd64/latest buster main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-6.7.2-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-6.7.2-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.9.1_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.5.0_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.25.1_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.0.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.1.1_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.14.3_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.6.1_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.2_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.0_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=a93af5d03b649cc8d84333568a349876f299cb58f4383981338262022a1ff068
    concourse-fly: sha256=974ec56d3b43e7ef77fa8fc43b0652a308b39e8d860191f861812e7111af20bc
    consul: sha256=9ba45ec6eb3e762444f077ae06e407ca5161d46785d725d7b5ea0c4d5cd5a99b
    consul-esm: sha256=96dae821bd3d1775048c9dbe8d6112ed645c9b912786c167ba9417f59509059d
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=58356ec125c85b9705dc7734ed4be8491bb4152d8a816fd0807aed5fbb128a7b
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=f384132204e906d653cce0fd6fa2dbe8edf26d50c319d824aa3a5e9184508fe0
    nomad-autoscaler: sha256=4e3fcd16ad1dc8fad3d66b76c452649a4e4dc53ce9d95e541aa04518479396c4
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=aa7b6cb6f366ffb920083b2a9739079ee560240ca31b580fe422af4af28cbb5a
    vault: sha256=75cd2b8c5527577c0da1105e11fba3c31f4112514a910c4f7ec527c9a8bf42d1
    vault-auditor: sha256=95b77f20d6015dfd612213b61b03e830d127f235f80533076326ebc753d94145
    vault-gpg-plugin: sha256=eee08f28f4be8889fefa097b45819eca857d374ee856d3cd803207ede0c559d3
    vault-ssh-helper: sha256=a88825a0cbf47aab9a8166930b4c7cb9dcfdc7b335fdcc2b2966b1baf5e251bf
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
