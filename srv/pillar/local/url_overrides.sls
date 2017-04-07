# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb http://fileserver.maurusnet.test/repo/ debian-stretch main
    jenkins: deb http://fileserver.maurusnet.test/jenkins/ jenkins main
    stretch: deb http://fileserver.maurusnet.test/debian/ stretch main
    stretch-backports: deb http://fileserver.maurusnet.test/debian/ stretch-backports main
    stretch-security: deb http://fileserver.maurusnet.test/debian/security/ stretch-updates main
    stretch-updates: deb http://fileserver.maurusnet.test/debian/ stretch-updates main
    maurusnet-nightly: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ stretch-pgdg main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/8/amd64/latest jessie main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.8.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.18.2_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.5.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.5.5_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://fileserver.maurusnet.test/downloads/qmail/qmail-1.03.tar.gz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.8.8_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.7.0_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=315f9efce095b2f0fa98059f99ef28d76bd845940322eb2d312d047747f59365
    consul: sha256=f4051c2cab9220be3c0ca22054ee4233f1396c7138ffd97a38ffbcea44377f47
    consul-template: sha256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=13ecd22bbbffab5b8261c2146af54fdf96a22c46c6618d6b5fd0f61938b95068
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    terraform: sha256=403d65b8a728b8dffcdd829262b57949bce9748b91f2e82dfd6d61692236b376
    vault: sha256=c6d97220e75335f75bd6f603bb23f1f16fe8e2a9d850ba59599b1a0e4d067aaa
    fpmdeps: sha256=8db50af6a4a67746f18fdd4e2f93c51faa90d7faea0eb44bf24f1fb730b76f97
