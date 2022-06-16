# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    bullseye: deb http://ftp-stud.hs-esslingen.de/debian/ bullseye main contrib
    bullseye-backports: deb http://ftp-stud.hs-esslingen.de/debian/ bullseye-backports main
    bullseye-security: deb http://security.debian.org/debian-security bullseye-security main
    bullseye-updates: deb http://deb.debian.org/debian bullseye-updates main
    docker: deb https://download.docker.com/linux/debian bullseye stable
    envoy: deb [arch=amd64] https://deb.dl.getenvoy.io/public/deb/debian bullseye main
    haproxy: deb http://haproxy.debian.net bullseye-backports-2.4 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/bullseye/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/bullseye/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/bullseye/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main
    # use buster packages until Salt releases for Bullseye
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v7.8.1/concourse-7.8.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.8.1/fly-7.8.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.12.2/consul_1.12.2_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.6.1/consul-esm_0.6.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.29.0/consul-template_0.29.0_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.3.1/nomad_1.3.1_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.7/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview2/nomad-pack_0.0.1-techpreview2_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.2.3/terraform_1.2.3_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.10.4/vault_1.10.4_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.5.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


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
