# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    bookworm: deb http://fileserver.maurusnet.test/debian/ bookworm main
    bookworm-backports: deb http://fileserver.maurusnet.test/debian/ bookworm-backports main
    bookworm-security: deb http://fileserver.maurusnet.test/debian/security/ bookworm-security main
    bookworm-updates: deb http://fileserver.maurusnet.test/debian/updates/ bookworm-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ bookworm stable
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ bookworm-backports-2.8 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ bookworm-pgdg
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/11/amd64/latest bookworm main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.0.4.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.9.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.9.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.16.1_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.33.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.6.2_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.5.7_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.14.3_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=da17ce61a5a0b64b74b7a53cb28c37437ea04b880ee8e6649bf112f32724ec4e
    concourse-fly: sha256=6cf7acfcde78a980339cba1534c01be28d360306e5c76c60c5546e3847434eb7
    consul: sha256=1d48942fa9f1d0df3f56a1622c7a46e9b85924ed9976338912101bb5519aadf1
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=eea287d363e52894d4698f40b0ac667d57443b20e3317792ec2aca0161fd6c81
    nomad: sha256=f6f879a359a667a6b1ca4366abd8383d89118dabd0d28af5bbc4721685ff17b8
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c
    vault: sha256=01e1698d2563cf4780438468f9f815eedf707e8ea01f87bb7621e24a00e21d12
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
