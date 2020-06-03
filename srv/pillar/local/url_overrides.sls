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
    envoy: deb [arch=amd64] http://fileserver.maurusnet.test/getenvoy-deb/ buster stable
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ buster-backports-2.1 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ buster-pgdg
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/10/amd64/latest buster main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-6.2.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-6.2.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.7.3_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.25.0_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.11.2_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.0.1-techpreview2_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.12.26_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.4.2_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=2cd2a48ed96fe51f2f4258199264ba2b7dd8a6be0ffb33a60a6beb83fc4e9ceb
    concourse-fly: sha256=79989c14e781ff50a09d92fe374398e8dd9bf1445585d82c153ddae895a9fdba
    consul: sha256=453814aa5d0c2bc1f8843b7985f2a101976433db3e6c0c81782a3c21dd3f9ac3
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=496da8d30242ab2804e17ef2fa41aeabd07fd90176986dff58bce1114638bb71
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=0c190d3cca12b75645e946e49207bf62bff8e0d8f52eee43dc059dbb8814da99
    nomad-autoscaler: sha256=d6ad76e1403bd20d02737aadd48dfe99c7f9b0f0e1656505d6f98f7a4e21b966
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=607bc802b1c6c2a5e62cc48640f38aaa64bef1501b46f0ae4829feb51594b257
    vault: sha256=f2bca89cbffb8710265eb03bc9452cc316b03338c411ba8453ffe7419390b8f1
    vault-gpg-plugin: sha256=d6ebf6457a7ccf3294c557d4b33b7ded66d74feb761e3e056ddced1fdaed4fba
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
