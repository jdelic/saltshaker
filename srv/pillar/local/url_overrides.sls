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
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/10/amd64/latest bullseye main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.5.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.5.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.10.3_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.6.0_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.27.1_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.1.6_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.3_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.0.9_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.8.4_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=cbd39b561f014d580ca03ec470badd1943a07467b7de62a0021bda2948a4cc6d
    concourse-fly: sha256=98e492f882533c079518b9958d45959ae7041dce090326b828abdb59d9795913
    consul: sha256=50afd45daaffd3af5ab67b03ff616117eca9961014ca0ef25ed2aaa27a7be698
    consul-esm: sha256=161a9df2b69a73e70004aef2908a8fd4cbcd86b3586d892934b3c9e7f6fbea94
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=db340b7555105d004caf8fad10e1d53ee0bd2320572c4560387279e92490f807
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=93f287758a464930e35cd1866167f05a3a6a48af2b0e010dfc0fbc914ae2f830
    nomad-autoscaler: sha256=8d4f1fbcf93cf637e042f3dcd8894f8653f501cfb5de6978481b961c8a4ddfa4
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=f06ac64c6a14ed6a923d255788e4a5daefa2b50e35f32d7a3b5a2f9a5a91e255
    vault: sha256=ceb0919c849c21627ca1cae060f361b6fb97dcf04b17d1d7d1dc9953fcd8e329
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=eee08f28f4be8889fefa097b45819eca857d374ee856d3cd803207ede0c559d3
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
