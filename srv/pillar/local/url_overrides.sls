# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb http://fileserver.maurusnet.test/repo/ debian-stretch main
    stretch: deb http://fileserver.maurusnet.test/debian/ stretch main
    stretch-backports: deb http://fileserver.maurusnet.test/debian/ stretch-backports main
    stretch-security: deb http://fileserver.maurusnet.test/debian/security/ stretch-updates main
    stretch-updates: deb http://fileserver.maurusnet.test/debian/ stretch-updates main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ stretch-pgdg main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/9/amd64/latest stretch main
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ stretch-backports-1.8 main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-5.2.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-5.2.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.5.0_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.3.2_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.20.0_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.9.1_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.11.13_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.1.2_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=e60750b11899ea150aeb7121870ebf7aaea08bab6e2ed88bfbf07c899ec9217f
    concourse-fly: sha256=ac6c0d87e0b5371f28edebb84972c0ca04d1c8eded67949b983f5bfa84ecf489
    consul: sha256=1399064050019db05d3378f757e058ec4426a917dd2d240336b51532065880b6
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
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
