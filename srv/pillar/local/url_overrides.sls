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
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.0.7.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.11.2-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.11.2-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.19.1_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.7.2_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.39.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.8.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.4_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.1.2_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.9.2_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.17.2_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=c2061e70cc8ee42a9a209a7c76ce6565fff7373cd59619b34846bfb435596230
    concourse: sha256=9de8cf177372e6afa907700c2ae5f943c9e7ac258aea6afbc6b0fe3ec728d985
    concourse-fly: sha256=0a318fe9df56d8299a8abd863aeb4e1e9632e6c91da92abef19984bd1910d8e2
    consul: sha256=aa48085aaa6f4130d0f1ee98c416dcd51b1b0f980d34f5b91834fd5b3387891c
    consul-esm: sha256=c6ad998ac5599eacddc54800355c39d289e486f5a61e3d92a5580895e4e8bdd5
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=10e7eba0acc307ab6500e49f75bdb95d8c7273266822e936f78a1c72425e7f4f
    nomad: sha256=29f91e539562bd377b9ecb82dd928526e24d0ef2b11537960fbbbb200713dc36
    nomad-autoscaler: sha256=bce4a2f3472228088a5a36accbffa242f1069d507451405192dc71bdb21a9233
    nomad-pack: sha256=7b89d9652e8622a99270fbbbc7fb457383d9f624faceaa41d2292bacd37a51ae
    terraform: sha256=d5f5aaba0f8ebff88ef0b23935872e154e2abf3172596261be834605ba3ba714
    vault: sha256=a0c0449e640c8be5dcf7b7b093d5884f6a85406dbb86bbad0ea06becad5aaab8
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
