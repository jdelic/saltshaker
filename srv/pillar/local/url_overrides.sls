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
    maurusnet-nightly: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/opensmtpd/ mn-experimental main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ jessie-pgdg main
    powerdns: deb http://fileserver.maurusnet.test/powerdns/ jessie-auth-40 main
    stretch-testing: deb http://fileserver.maurusnet.test/debian/ stretch main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/8/amd64/latest jessie main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.7.4_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.18.0_linux_amd64.zip
    consul-webui: http://fileserver.maurusnet.test/downloads/consul/consul_0.7.4_web_ui.zip
    djbdns: http://fileserver.maurusnet.test/downloads/djbdns/djbdns-1.05.tar.gz
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.5.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.5.4_linux_amd64.zip
    pyrun34: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.1-py3.4_ucs4-linux-x86_64.tgz
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.1-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://fileserver.maurusnet.test/downloads/qmail/qmail-1.03.tar.gz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.7.1_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.6.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=315f9efce095b2f0fa98059f99ef28d76bd845940322eb2d312d047747f59365
    consul: sha256=23a61773bee9b29198cc1f8fe2e62c320f82f95006ff70840c15c1e58eead73b
    consul-template: sha256=f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b
    consul-webui: sha256=3d2ef4035b53dc448c8b2db7835e96d3d0365a2577f5a0b316c8dfc726f34a64
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=ed9eb471b9f5bab729cfa402db5aa56e1d935c328ac48327267e0ea53568d5c2
    pyrun34: sha256=9798f3cd00bb39ee07daddb253665f4e3777ab58ffb6b1d824e206d338017e71
    pyrun35: sha256=d20bd23b3e6485c0122d4752fb713f30229e7c522e4482cc9716afc05413b02e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    terraform: sha256=133766ed558af04255490f135fed17f497b9ba1e277ff985224e1287726ab2dc
    vault: sha256=04d87dd553aed59f3fe316222217a8d8777f40115a115dac4d88fac1611c51a6
    fpmdeps: sha256=8db50af6a4a67746f18fdd4e2f93c51faa90d7faea0eb44bf24f1fb730b76f97
