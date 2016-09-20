# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb http://fileserver.maurusnet.test/repo/ debian-jessie main
    jenkins: deb http://fileserver.maurusnet.test/jenkins/ jenkins main
    jessie: deb http://fileserver.maurusnet.test/debian/ jessie main
    jessie-backports: deb http://fileserver.maurusnet.test/debian/ jessie-backports main
    jessie-security: deb http://fileserver.maurusnet.test/debian/security/ jessie-updates main
    jessie-updates: deb http://fileserver.maurusnet.test/debian/ jessie-updates main
    maurusnet: deb http://fileserver.maurusnet.test/maurusnet/ jessie main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ jessie-pgdg main
    powerdns: deb http://fileserver.maurusnet.test/powerdns/ jessie-auth-40 main
    stretch-testing: deb http://fileserver.maurusnet.test/debian/ stretch main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/8/amd64/latest jessie main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key

urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.7.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.15.0_linux_amd64.zip
    consul-webui: http://fileserver.maurusnet.test/downloads/consul/consul_0.7.0_web_ui.zip
    djbdns: http://fileserver.maurusnet.test/downloads/djbdns/djbdns-1.05.tar.gz
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.5.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.4.1_linux_amd64.zip
    pyrun34: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.1-py3.4_ucs4-linux-x86_64.tgz
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.1-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://fileserver.maurusnet.test/downloads/qmail/qmail-1.03.tar.gz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.7.1_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.6.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip

hashes:
    concourse: sha256=095be90b5f7baf0d32e72633b7f23dae5f372aa74751186cfb5dcd1b40abafff
    consul: sha256=b350591af10d7d23514ebaa0565638539900cdb3aaa048f077217c4c46653dd8
    consul-template: sha256=b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a
    consul-webui: sha256sum=42212089c228a73a0881a5835079c8df58a4f31b5060a3b4ffd4c2497abe3aa8
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    exxo: sha256=3c8e7a9cbe2f88b7c67d4e970f60de7f63a9ce4206aaf214326ead49cc5a2396
    nomad: sha256sum=0cdb5dd95c918c6237dddeafe2e9d2049558fea79ed43eacdfcd247d5b093d67
    pyrun34: sha256sum=9798f3cd00bb39ee07daddb253665f4e3777ab58ffb6b1d824e206d338017e71
    pyrun35: sha256sum=d20bd23b3e6485c0122d4752fb713f30229e7c522e4482cc9716afc05413b02e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    terraform: sha256=133766ed558af04255490f135fed17f497b9ba1e277ff985224e1287726ab2dc
    vault: sha256=4f248214e4e71da68a166de60cc0c1485b194f4a2197da641187b745c8d5b8be
    fpmdeps: sha256=e5fde6513911713c52a9b8833031bcea373809088e367f2ab5524c5a01719b02
