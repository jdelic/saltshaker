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
    concourse: https://github.com/concourse/concourse/releases/download/v7.7.1/concourse-7.7.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.7.1/fly-7.7.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.12.0/consul_1.12.0_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.6.0/consul-esm_0.6.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.29.0/consul-template_0.29.0_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.2.6/nomad_1.2.6_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.6/nomad-autoscaler_0.3.6_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview2/nomad-pack_0.0.1-techpreview2_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.10.0/vault_1.10.0_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.5.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    concourse: sha256=f9c39c9e1e7a8c0f3f847f53da532a4ea05665d40c8a744daec3a01f0cddbed8
    concourse-fly: sha256=cbb2c7e3bed15c6f91cf01810c58ee82be0511e5f2ccf314ab6f15a9f4852ece
    consul: sha256=109e2077236cae4560b2fa3dce7974ef58d6a7093d72494614d875e5c86e3b2c
    consul-esm: sha256=161a9df2b69a73e70004aef2908a8fd4cbcd86b3586d892934b3c9e7f6fbea94
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=3afe87115cf1b77196c7a4daab6429e495cd307c49deab255ff2adf2b3923541
    nomad: sha256=a7bee57db3c3a595ecba964f7afee9c32ebb6799eb7a1682deb0a7cd8e7d08c0
    nomad-autoscaler: sha256=2f3a55078f2c993a751b9e644dd07573ee2183871f21274159d5c7e4860f6421
    nomad-pack: sha256=d4ad91494f8b8bff58a27181fc7a0b6fc9fd47967aba92e107b549c17bf1f4f2
    terraform: sha256=9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a
    vault: sha256=ec06473d79e77c05700f051278c54b0f7b6f2df64f57f630a0690306323f1175
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
