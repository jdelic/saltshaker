# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    bullseye: deb http://ftp-stud.hs-esslingen.de/debian/ bullseye main contrib
    bullseye-backports: deb http://ftp-stud.hs-esslingen.de/debian/ bullseye-backports main
    bullseye-security: deb http://security.debian.org/debian-security bullseye-security main
    bullseye-updates: deb http://deb.debian.org/debian bullseye-updates main
    docker: deb https://download.docker.com/linux/debian bullseye stable
    envoy: deb [arch=amd64] https://deb.dl.getenvoy.io/public/deb/debian bullseye main
    haproxy: deb http://haproxy.debian.net bullseye-backports-2.4 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/bullseye/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/bullseye/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/bullseye/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main
    # use buster packages until Salt releases for Bullseye
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v7.6.0/concourse-7.6.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.6.0/fly-7.6.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.11.2/consul_1.11.2_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.6.0/consul-esm_0.6.0_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.27.2/consul-template_0.27.2_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/1.2.4/nomad_1.2.4_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.5/nomad-autoscaler_0.3.5_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview1/nomad-pack_0.0.1-techpreview1_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.9.2/vault_1.9.2_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.5.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


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
