# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    docker: deb https://apt.dockerproject.org/repo debian-stretch main
    jenkins: deb http://pkg.jenkins-ci.org/debian binary/
    stretch: deb http://ftp-stud.hs-esslingen.de/debian/ stretch main contrib
    stretch-backports: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-backports main
    stretch-security: deb http://security.debian.org/ stretch/updates main
    stretch-updates: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-updates main
    maurusnet: deb http://repo.maurus.net/debian/ jessie main
    maurusnet-nightly: deb http://repo.maurus.net/nightly/stretch/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/stretch/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
    saltstack: deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v2.7.0/concourse_linux_amd64
    consul: https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.18.2/consul-template_0.18.2_linux_amd64.zip
    consul-webui: https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_web_ui.zip
    djbdns: http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.5.5/nomad_0.5.5_linux_amd64.zip
    pyrun34: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.4_ucs4-linux-x86_64.tgz
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://cr.yp.to/software/qmail-1.03.tar.gz
    terraform: https://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.7.0/vault_0.7.0_linux_amd64.zip


hashes:
    concourse: sha256=315f9efce095b2f0fa98059f99ef28d76bd845940322eb2d312d047747f59365
    consul: sha256=40ce7175535551882ecdff21fdd276cef6eaab96be8a8260e0599fadb6f1f5b8
    consul-template: sha256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c
    consul-webui: sha256=a7803e7ba2872035a7e1db35c8a2186ad238bf0f90eb441ee4663a872b598af4
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=13ecd22bbbffab5b8261c2146af54fdf96a22c46c6618d6b5fd0f61938b95068
    pyrun34: sha256=9798f3cd00bb39ee07daddb253665f4e3777ab58ffb6b1d824e206d338017e71
    pyrun35: sha256=d20bd23b3e6485c0122d4752fb713f30229e7c522e4482cc9716afc05413b02e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    terraform: sha256=403d65b8a728b8dffcdd829262b57949bce9748b91f2e82dfd6d61692236b376
    vault: sha256=c6d97220e75335f75bd6f603bb23f1f16fe8e2a9d850ba59599b1a0e4d067aaa
