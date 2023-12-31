# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    bookworm: deb http://fileserver.maurusnet.test/debian/ bookworm main
    bookworm-backports: deb http://fileserver.maurusnet.test/debian/ bookworm-backports main
    bookworm-security: deb http://fileserver.maurusnet.test/debian/security/ bookworm-security main
    bookworm-updates: deb http://fileserver.maurusnet.test/debian/updates/ bookworm-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ bookworm stable
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ bookworm-backports-2.8 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ bookworm-pgdg
    saltstack: deb http://fileserver.maurusnet.test/salt/py3/debian/12/amd64/latest bookworm main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.0.4.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.11.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.11.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.17.1_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.35.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.7.2_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.0_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.6.6_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.15.4_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=ef75c157c15b4672e432ab6eea8cbc0d6db600747a0f0ec0f3c6536c9ff8eb25
    concourse-fly: sha256=c49a654eadbdf190799393fa03fe264ccb41302153e3b6208f32de5092334f57
    consul: sha256=388889321d6aaf389ee87acc247ea9885e684a1581c8ebfbeab7348abd7c0214
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=1b1c9127e8da25b2d7322e6f2aa8e6d946336083999e0fdb321f96ffd447eebd
    nomad: sha256=5264b4f4b9a0bf8f086544f15e6a6377c856e5556bf44337c958f5356d251331
    nomad-autoscaler: sha256=99a6104f44ef8642ef414a640345ae0172ffd168ac5e535a1e81437748f91733
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=d117883fd98b960c5d0f012b0d4b21801e1aea985e26949c2d1ebb39af074f00
    vault: sha256=f42f550713e87cceef2f29a4e2b754491697475e3d26c0c5616314e40edd8e1b
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=943c17330e9933863be7de8a6fc69e00bd871aef4d62a36404b384278d87cfc5
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
