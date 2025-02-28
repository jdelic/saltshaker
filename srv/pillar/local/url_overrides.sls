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
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.1.0.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.12.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.12.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.20.4_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.8.0_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.40.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.9.6_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.6_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.2.0_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.11.0_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.18.5_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=1e00a4d2df81ded9987840671ad5b5c75f17ac0f2f6f87c647b7051e71a13de3
    concourse: sha256=669131180f1b3d9e30b32fd139586acbca4d762386ea481055736d6361499d43
    concourse-fly: sha256=dd1e5f94214632a09ce07426c2392ab8803ae8b307c0ba5436239e9b67d01c52
    consul: sha256=dc8ef4b721928f5ceb29689c4811b43bf776a1f43845a0bb1c851e313cb845b2
    consul-esm: sha256=8ad873fdee0b38b5b51830b5218b04d3fe60ee47dc1d6993ce431d5ed91f223c
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=f73cb36988b9aaccb0ac918df26c854ccd199e60c0df011357405672f3d934bc
    nomad: sha256=2a34f08154e5ac72c43bfe56bec1836028c5b3fff3468915a9cffcf6cd2cdf52
    nomad-autoscaler: sha256=4cb2b009f2ba886d9024b44863e79022cad6483ff7586d574eb466804f647e19
    nomad-pack: sha256=32533e635b78101056f411366e26aca7778ea80f8556002f825784e1d75a4437
    terraform: sha256=069e531fd4651b9b510adbd7e27dd648b88d66d5f369a2059aadbb4baaead1c1
    vault: sha256=dfd8619affbc6449a2f8b23a04f1e8632a00e9b8010b49f7f5daf253d181129d
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
