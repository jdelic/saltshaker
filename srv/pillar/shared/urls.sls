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
    haproxy: deb http://haproxy.debian.net stretch-backports-1.9 main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v5.5.0/concourse-5.5.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v5.5.0/fly-5.5.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.5.3/consul_1.5.3_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.3.3/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.20.1/consul-template_0.20.1_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.9.4/nomad_0.9.4_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.2.0/vault_1.2.0_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.2.2/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.4/vault-ssh-helper_0.1.4_linux_amd64.zip


hashes:
    concourse: sha256=d347c5f3b0f529f733fb76f8e15508e033286376ce62852fcf16112e8ecf2772
    concourse-fly: sha256=f12d176d809711765cb0b9782c5a4c169530500cd05da32a7dda65e1b5c2d221
    consul: sha256=b402e1a0db26adb9638a9e85c6c672acd137df233e8c69f26180f2e2fd6f4cbc
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=c5d6bb528ba1828b619147e482625d9fc3acc23f70eb97e03d590a31c9385c08
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=e0cdd0d787bb925910151f9e38fd6daa9590f1bf08d0c6703b7f544875b58c11
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=6544eb55b3e916affeea0a46fe785329c36de1ba1bdb51ca5239d3567101876f
    vault: sha256=392b45f0978791d2050c02835494f220f40b70896903197dd9f95033f8855358
    vault-gpg-plugin: sha256=8826ea137898e572bef7d27b6544b4f46e42119c3c83f668858a529ff82ad8bd
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
