# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    bookworm: deb http://ftp-stud.hs-esslingen.de/debian/ bookworm main contrib
    bookworm-backports: deb http://ftp-stud.hs-esslingen.de/debian/ bookworm-backports main
    bookworm-security: deb http://security.debian.org/debian-security bookworm-security main
    bookworm-updates: deb http://deb.debian.org/debian bookworm-updates main
    docker: deb https://download.docker.com/linux/debian bookworm stable
    haproxy: deb [signed-by=/usr/share/keyrings/haproxy.debian.net.gpg] http://haproxy.debian.net bookworm-backports-2.8 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/bookworm/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/bookworm/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/bookworm/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/debian/11/amd64/latest bookworm main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.0.4.zip
    concourse: https://github.com/concourse/concourse/releases/download/v7.9.1/concourse-7.9.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v7.9.1/fly-7.9.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.16.1/consul_1.16.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.7.1/consul-esm_0.7.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.33.0/consul-template_0.33.0_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.6.2/nomad_1.6.2_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.3.7/nomad-autoscaler_0.3.7_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.0.1-techpreview.3/nomad-pack_0.0.1-techpreview.3_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.14.3/vault_1.14.3_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.5.0/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=8f02886f809df01ef79ef3314f09876b04cc144a9460d4e5755a32bcb2dc1c84
    concourse: sha256=da17ce61a5a0b64b74b7a53cb28c37437ea04b880ee8e6649bf112f32724ec4e
    concourse-fly: sha256=6cf7acfcde78a980339cba1534c01be28d360306e5c76c60c5546e3847434eb7
    consul: sha256=1d48942fa9f1d0df3f56a1622c7a46e9b85924ed9976338912101bb5519aadf1
    consul-esm: sha256=bc1d8c351d277bb1e93d3d2a209b9282ee5d84e3a82ce3c38281f40318b5268f
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=eea287d363e52894d4698f40b0ac667d57443b20e3317792ec2aca0161fd6c81
    nomad: sha256=f6f879a359a667a6b1ca4366abd8383d89118dabd0d28af5bbc4721685ff17b8
    nomad-autoscaler: sha256=11d3c8a5d16020514a55775f5b83fc8f1a08e2a2274f97b06700a5d9877346b4
    nomad-pack: sha256=825cbe6f6053ad4eab4bc298a901cb957b6331fdb3db4b6a896e620a2b96f3c3
    terraform: sha256=c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c
    vault: sha256=01e1698d2563cf4780438468f9f815eedf707e8ea01f87bb7621e24a00e21d12
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=f6ca9f3575802e46c723c9b2a21af261e37729a1c5e49a2977578f69d17d4aca
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
