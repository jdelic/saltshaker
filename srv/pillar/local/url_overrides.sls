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
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.8.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.8.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.12.2_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.6.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.29.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.3.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview2_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.2.3_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.10.4_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=4bc525aabd757e60c4b20af86d791aaa41fa84ee8ae27b852c71231283bec454
    concourse-fly: sha256=0f84ea05cbab7351278ccde869caee06c3613adc298939e060bf3e8ed414936e
    consul: sha256=35f85098f5956ef3aca66ec2d2d2a803d1f3359b4dec13382c6ac895344a1f4c
    consul-esm: sha256=d46a1797ecf511719d0b6e0220d7493a0dd3d559b15a81538d09f40522953e61
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=9178437bde1f0f220010f17806c01b36ccb3814f065d4ebdfba53ade9832012d
    nomad: sha256=d16dcea9fdfab3846e749307e117e33a07f0d8678cf28cc088637055e34e5b37
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=d4ad91494f8b8bff58a27181fc7a0b6fc9fd47967aba92e107b549c17bf1f4f2
    terraform: sha256=728b6fbcb288ad1b7b6590585410a98d3b7e05efe4601ef776c37e15e9a83a96
    vault: sha256=0cfa7796139baf58365e10c4a353e72e56ef6332f4c9a4e66b6ae9a244167346
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
