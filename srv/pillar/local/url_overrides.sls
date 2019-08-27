# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    buster: deb http://fileserver.maurusnet.test/debian/ buster main
    buster-backports: deb http://fileserver.maurusnet.test/debian/ buster-backports main
    buster-security: deb http://fileserver.maurusnet.test/debian/security/ buster-updates main
    buster-updates: deb http://fileserver.maurusnet.test/debian/ buster-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ buster stable
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ buster-pgdg main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/9/amd64/latest stretch main
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ buster-backports-2.0 main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-5.4.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-5.4.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.6.0_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.21.0_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.9.5_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.12.7_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.2.0_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=74711d5825ac831fbbe6c3e7dbce81d661da1c565bed382da75acfaae8c92ff7
    concourse-fly: sha256=4766721fc05e376d8239ffa9a4fc42b8bb18c4fb66577d2423c7095810eb0181
    consul: sha256=06b9993384e5fad901e0a70185b198dc74f3f34e1660a40f194cd6095b5d59d4
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=2ac864562efb48b9edb69646d47423e7f2b6d06e44767f369a6cd2c912863f4e
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=9a137abad26959b6c5f8169121f1c7082dff7b11b11c7fe5a728deac7d4bd33f
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=6544eb55b3e916affeea0a46fe785329c36de1ba1bdb51ca5239d3567101876f
    vault: sha256=7725b35d9ca8be3668abe63481f0731ca4730509419b4eb29fa0b0baa4798458
    vault-gpg-plugin: sha256=8826ea137898e572bef7d27b6544b4f46e42119c3c83f668858a529ff82ad8bd
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
