# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/aptly-archive.gpg arch=amd64] http://repo.aptly.info/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/aptly-nightly-archive.gpg arch=amd64] http://repo.aptly.info/ nightly main
    docker: deb [signed-by=/etc/apt/keyrings/docker-archive.gpg arch=amd64] https://download.docker.com/linux/debian trixie stable
    haproxy: deb [signed-by=/etc/apt/keyrings/haproxy-archive-keyring.gpg arch=amd64] http://haproxy.debian.net trixie-backports-3.2 main
    maurusnet: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/release/trixie mn-release main
    postgresql: deb [signed-by=/etc/apt/keyrings/postgresql-archive.gpg arch=amd64] http://apt.postgresql.org/pub/repos/apt/ trixie-pgdg main
    saltstack: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://packages.broadcom.com/artifactory/saltproject-deb/ stable main
    trixie: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://ftp-stud.hs-esslingen.de/debian/ trixie main contrib
    trixie-backports: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://ftp-stud.hs-esslingen.de/debian/ trixie-backports main
    trixie-security: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://security.debian.org/debian-security trixie-security main
    trixie-updates: deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg arch=amd64] http://deb.debian.org/debian trixie-updates main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    acme: https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.1.2.zip
    concourse: https://github.com/concourse/concourse/releases/download/v8.1.0/concourse-8.1.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v8.1.0/fly-8.1.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.22.5/consul_1.22.5_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.41.4/consul-template_0.41.4_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.11.2/nomad_1.11.2_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.9/nomad-autoscaler_0.4.9_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.21.3/vault_1.21.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=aeaab9a47db011b0cc8720b77158948044e7580c2168bc957268473cf6112817
    concourse-fly: sha256=e8ef5afa9789e149a7bcf76921a063a5414bf8239ac3ae62cb880f03f40b862c
    consul: sha256=58603b87fd085282f882fcd02b5165c93b321692514b2ab822dec8dd4cd028a3
    consul-template: sha256=9e999cfbfdc47e67d3d91e6e4edbecaa3d7c3b026307b18c0485b64d15e5083a
    nomad: sha256=e042b0f6f6648b149be7cfddac832214cf8ca17725e5f0e420b5b0547532bdcd
    nomad-autoscaler: sha256=4b89c4d266663c9795b32930199c489a67606ac13f03e7fca8da15a0513a6ca7
    nomad-driver-podman: sha256=5b9ac89585d7359f941a2504b11d50866f67c2887cb3716fba2bbaa0749a14a8
    nomad-pack: sha256=08e213dfe76152b512da9fd8c57c24365812a43c96deda6f88cde26aab03310b
    vault: sha256=c945e90979a7b6e4b4846285587c35b25f8191f9f70cb879132bc118ae42c368
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
