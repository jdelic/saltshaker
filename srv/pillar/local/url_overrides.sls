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
    saltstack: deb http://fileserver.maurusnet.test/salt/py3/debian/12/amd64/latest bookworm main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.0.4.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.11.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.11.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.18.1_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.37.4_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.7.6_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.3_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.1.0_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.8.0_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.16.1_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=fa48ad44c6973e6537e54f9e586f1d9ccb14526b216c3788eaee3290b07df0be
    concourse-fly: sha256=7ac3fda96ae193bee95f92fdbc9decfc563cd14393882e47520ab67fa1a075f5
    consul: sha256=5faa9cc3f2832e3ae454a3ec2dbc6799179d14e1e09463f220bb906c590f4b05
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=f43567923e57f1e8ad30b07a3bc0a303b7213d13a5ad5c1ed7b3a9ea09be8275
    nomad: sha256=82a438a144066a8f42ceea8548da754c0bd96b5b528cd337a5dc09017afddb56
    nomad-autoscaler: sha256=c66e352accca50413202f88144e5aa2211c185f6a58a1061df38c42753f0f0a0
    nomad-pack: sha256=20604ae26caffc506a5f6ad993bc8925f6022d1875c678e91a0897e1a2411288
    terraform: sha256=858e2ca2d38ce3644607af68eb5184a91493feecf82346deb386fd6cfbfad785
    vault: sha256=315a1964d7003ef6de94c407a88972d45eb9b378946a53a1bbff34de1ae2d1e0
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
