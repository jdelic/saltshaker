# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    docker: deb https://apt.dockerproject.org/repo debian-jessie main
    jenkins: deb http://pkg.jenkins-ci.org/debian binary/
    jessie: deb http://ftp-stud.hs-esslingen.de/debian/ jessie main contrib
    jessie-backports: deb http://ftp-stud.hs-esslingen.de/debian/ jessie-backports main
    jessie-security: deb http://security.debian.org/ jessie/updates main
    jessie-updates: deb http://ftp-stud.hs-esslingen.de/debian/ jessie-updates main
    maurusnet: deb http://repo.maurus.net/debian/ jessie main
    maurusnet-nightly: deb http://repo.maurus.net/nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/opensmtpd/ mn-experimental main
    maurusnet-radicale: deb http://repo.maurus.net/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main
    powerdns: deb http://repo.powerdns.com/debian jessie-auth-40 main
    stretch-testing: deb http://ftp-stud.hs-esslingen.de/debian/ stretch main
    saltstack: deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v2.6.0/concourse_linux_amd64
    consul: https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.18.0/consul-template_0.18.0_linux_amd64.zip
    consul-webui: https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_web_ui.zip
    djbdns: http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.5.4/nomad_0.5.4_linux_amd64.zip
    pyrun34: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.4_ucs4-linux-x86_64.tgz
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://cr.yp.to/software/qmail-1.03.tar.gz
    terraform: https://releases.hashicorp.com/terraform/0.7.1/terraform_0.7.1_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.6.4/vault_0.6.4_linux_amd64.zip


hashes:
    concourse: sha256=ba974aabc744e1c32f33a25720fdf3a40b176a040fb0ecdedb1d5862fa5ccb9c
    consul: sha256=aa97f4e5a552d986b2a36d48fdc3a4a909463e7de5f726f3c5a89b8a1be74a58
    consul-template: sha256=f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b
    consul-webui: sha256=c9d2a6e1d1bb6243e5fd23338d92f5c71cdf0a4077f7fcc95fd81800fa1f42a9
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=ed9eb471b9f5bab729cfa402db5aa56e1d935c328ac48327267e0ea53568d5c2
    pyrun34: sha256=9798f3cd00bb39ee07daddb253665f4e3777ab58ffb6b1d824e206d338017e71
    pyrun35: sha256=d20bd23b3e6485c0122d4752fb713f30229e7c522e4482cc9716afc05413b02e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    terraform: sha256=133766ed558af04255490f135fed17f497b9ba1e277ff985224e1287726ab2dc
    vault: sha256=04d87dd553aed59f3fe316222217a8d8777f40115a115dac4d88fac1611c51a6
