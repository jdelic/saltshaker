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

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v3.6.0/concourse_linux_amd64
    consul:  https://releases.hashicorp.com/consul/1.0.0/consul_1.0.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.7.0/nomad_0.7.0_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.8.3/vault_0.8.3_linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.3/vault-ssh-helper_0.1.3_linux_amd64.zip


hashes:
    concourse: sha256=87132e62f227e776b10178c21c83eb9f0049e4b53adc4e4dbb7eb06dfbb2e3b1
    consul: sha256=585782e1fb25a2096e1776e2da206866b1d9e1f10b71317e682e03125f22f479
    consul-template: sha256=47b3f134144b3f2c6c1d4c498124af3c4f1a4767986d71edfda694f822eb7680
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=1751136e5b17bd28984e19768381cf5a626623089e9e1451f1c21e76230d016e
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=b786c0cf936e24145fad632efd0fe48c831558cc9e43c071fffd93f35e3150db
    vault: sha256=a3b687904cd1151e7c7b1a3d016c93177b33f4f9ce5254e1d4f060fca2ac2626
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
