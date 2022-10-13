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
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.13.2_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.6.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.29.5_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.4.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview2_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.3.2_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.12.0_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=34aa400c4ff3a7edd89f32d1504a9522efba13a28b887685f369d96fdbe922f5
    concourse-fly: sha256=e71ebc1ba96ffab29e7d9ad32c1fd90f94918b81b8b2173b988a31ebdc00e9ce
    consul: sha256=a72e88cbfec6c0fb3620cd58314ff0b42fc9d605a5192d6a568a417180f0b35f
    consul-esm: sha256=d46a1797ecf511719d0b6e0220d7493a0dd3d559b15a81538d09f40522953e61
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=24aa8c67a2ac95c03524d62dd0e1815359e8c9689324b48e9c75ed2b6e25a5c8
    nomad: sha256=f9327818a97fc2f29b6a9283c3175cd13ba6c774c15ee5683035c23b9a3640fa
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=d4ad91494f8b8bff58a27181fc7a0b6fc9fd47967aba92e107b549c17bf1f4f2
    terraform: sha256=6372e02a7f04bef9dac4a7a12f4580a0ad96a37b5997e80738e070be330cb11c
    vault: sha256=56d140b34bec780cd458672e39b3bb0ea9e4b7e4fb9ea7e15de31e1562130d7a
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
