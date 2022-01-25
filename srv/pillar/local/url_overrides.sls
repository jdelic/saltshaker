# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    bullseye: deb http://fileserver.maurusnet.test/debian/ bullseye main
    bullseye-backports: deb http://fileserver.maurusnet.test/debian/ bullseye-backports main
    bullseye-security: deb http://fileserver.maurusnet.test/debian/security/ bullseye-security main
    bullseye-updates: deb http://fileserver.maurusnet.test/debian/updates/ bullseye-updates main
    docker: deb http://fileserver.maurusnet.test/repo/ bullseye stable
    envoy: deb [arch=amd64] http://fileserver.maurusnet.test/envoy/ bullseye main
    haproxy: deb http://fileserver.maurusnet.test/haproxy/ bullseye-backports-2.2 main
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ bullseye-pgdg
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/10/amd64/latest bullseye main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.6.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.6.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.11.2_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.6.0_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.27.2_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.2.4_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.3.5_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.0.1-techpreview1_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.1.4_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.9.2_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=66db22e71808f8a710c00ae5f54ff54b09cfdf2a08252f2bdf7f6e5a7c04d707
    concourse-fly: sha256=c264d9cb979d05598e44e0527220e21e2f20564f63cc11f98c8480768997433f
    consul: sha256=380eaff1b18a2b62d8e1d8a7cbc3f3e08b34d3f7187ee335b891ca2ba98784b3
    consul-esm: sha256=161a9df2b69a73e70004aef2908a8fd4cbcd86b3586d892934b3c9e7f6fbea94
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=d3d428ede8cb6e486d74b74deb9a7cdba6a6de293f3311f178cc147f1d1837e8
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=51ae6aede9a2ec1bc73065b84881c5a4d67eeb1328ee5bf189b10c4f4e72805d
    nomad-autoscaler: sha256=3c2b4ada4600e0b5c57b20c20a934d42dab966500f66bb713a4d504ef21bac52
    nomad-pack: sha256=4928c48e714181d0c69f3a3dc8b45fbe2f9f1abdacbb700b5cfa71563355df53
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=fca028d622f82788fdc35c1349e78d69ff07c7bb68c27d12f8b48c420e3ecdfb
    vault: sha256=1e3eb5c225ff1825a59616ebbd4ac300e9d6eaefcae26253e49209350c0a5e71
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
