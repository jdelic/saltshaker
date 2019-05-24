# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    docker: deb https://apt.dockerproject.org/repo debian-stretch main
    stretch: deb http://ftp-stud.hs-esslingen.de/debian/ stretch main contrib
    stretch-backports: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-backports main
    stretch-security: deb http://security.debian.org/ stretch/updates main
    stretch-updates: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-updates main
    maurusnet-apps: deb http://repo.maurus.net/release/stretch/ mn-release main
    maurusnet-opensmtpd: deb http://repo.maurus.net/stretch/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
    saltstack: deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main
    haproxy: deb http://haproxy.debian.net stretch-backports-1.8 main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v5.2.0/concourse-5.2.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v5.2.0/fly-5.2.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.5.1/consul_1.5.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.3.2/consul-esm_0.3.2_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.9.1/nomad_0.9.1_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.1.2/vault_1.1.2_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.2.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.4/vault-ssh-helper_0.1.4_linux_amd64.zip


hashes:
    concourse: sha256=e60750b11899ea150aeb7121870ebf7aaea08bab6e2ed88bfbf07c899ec9217f
    concourse-fly: sha256=ac6c0d87e0b5371f28edebb84972c0ca04d1c8eded67949b983f5bfa84ecf489
    consul: sha256=58fbf392965b629db0d08984ec2bd43a5cb4c7cc7ba059f2494ec37c32fdcb91
    consul-esm: sha256=88af7cc2645187c52da88300d12dd10a76133055de8fd68353c7bea5dec76644
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=500fe023c89517f959175eb79e21c33df0acf7733d3f3681ec8c5238863caf86
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=7ae414ff78c920089946c3a6dfde8d5ce3b14ef42652a805004924b0c5ce5f20
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=5925cd4d81e7d8f42a0054df2aafd66e2ab7408dbed2bd748f0022cfe592f8d2
    vault: sha256=e927fd4daac11f6c7b8b3f1f53f2017516e29e99585dc975b657acdeac43500b
    vault-gpg-plugin: sha256=8826ea137898e572bef7d27b6544b4f46e42119c3c83f668858a529ff82ad8bd
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
