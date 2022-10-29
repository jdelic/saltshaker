# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    bullseye: deb http://fileserver.maurusnet.test/debian/ bullseye main
    bullseye-backports: deb http://fileserver.maurusnet.test/debian/ bullseye-backports main
    bullseye-security: deb http://fileserver.maurusnet.test/debian/security/ bullseye-security main
    bullseye-updates: deb http://fileserver.maurusnet.test/debian/updates/ bullseye-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ bullseye stable
    envoy: deb [arch=amd64] http://fileserver.maurusnet.test/envoy/ bullseye main
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ bullseye-backports-2.2 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ bullseye-pgdg
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/11/amd64/latest bullseye main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.0.4.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.8.3-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.8.3-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.13.3_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.6.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.29.5_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.4.2_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.3.3_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.12.0_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=34aa400c4ff3a7edd89f32d1504a9522efba13a28b887685f369d96fdbe922f5
    concourse-fly: sha256=e71ebc1ba96ffab29e7d9ad32c1fd90f94918b81b8b2173b988a31ebdc00e9ce
    consul: sha256=5370b0b5bf765530e28cb80f90dcb47bd7d6ba78176c1ab2430f56e460ed279c
    consul-esm: sha256=d46a1797ecf511719d0b6e0220d7493a0dd3d559b15a81538d09f40522953e61
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=24aa8c67a2ac95c03524d62dd0e1815359e8c9689324b48e9c75ed2b6e25a5c8
    nomad: sha256=6e24efd6dfba0ba2df31347753f615cae4d3632090e68fc90933e51e640f7afc
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=fa5cbf4274c67f2937cabf1a6544529d35d0b8b729ce814b40d0611fd26193c1
    vault: sha256=56d140b34bec780cd458672e39b3bb0ea9e4b7e4fb9ea7e15de31e1562130d7a
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
