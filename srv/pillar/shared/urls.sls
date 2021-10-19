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
    concourse: https://github.com/concourse/concourse/releases/download/v7.5.0/concourse-7.5.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.5.0/fly-7.5.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.10.3/consul_1.10.3_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.6.0/consul-esm_0.6.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.27.1/consul-template_0.27.1_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/1.1.6/nomad_1.1.6_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.3/nomad-autoscaler_0.3.3_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.8.4/vault_1.8.4_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.3.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


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
