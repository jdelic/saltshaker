# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/aptly-archive.gpg arch=amd64] http://repo.aptly.info/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/aptly-nightly-archive.gpg arch=amd64] http://repo.aptly.info/ nightly main
    docker: deb [signed-by=/etc/apt/keyrings/docker-archive.gpg arch=amd64] https://download.docker.com/linux/debian trixie stable
    haproxy: deb [signed-by=/etc/apt/keyrings/haproxy-archive-keyring.gpg arch=amd64] http://haproxy.debian.net trixie-backports-3.2 main
    maurusnet: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg arch=amd64] http://repo.maurus.net/nightly/trixie mn-nightly main
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
    concourse: https://github.com/concourse/concourse/releases/download/v8.0.1/concourse-8.0.1-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v8.0.1/fly-8.0.1-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.22.3/consul_1.22.3_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.9.1/consul-esm_0.9.1_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.41.4/consul-template_0.41.4_linux_amd64.zip
    nomad: https://releases.hashicorp.com/nomad/1.11.2/nomad_1.11.2_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.4.9/nomad-autoscaler_0.4.9_linux_amd64.zip
    nomad-driver-podman: https://releases.hashicorp.com/nomad-driver-podman/0.6.4/nomad-driver-podman_0.6.4_linux_amd64.zip
    nomad-pack: https://releases.hashicorp.com/nomad-pack/0.4.1/nomad-pack_0.4.1_linux_amd64.zip
    terraform: https://releases.hashicorp.com/terraform/1.14.5/terraform_1.14.5_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.21.3/vault_1.21.3_linux_amd64.zip
    vault-auditor: https://releases.hashicorp.com/vault-auditor/1.0.3/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=52fee46a10f638581e022b32052b9d28e116a04f113f607a5eae20b0e34132b8
    concourse-fly: sha256=77d03d5788512876ad348196a365c5dd982af6e1bebdc54ca22fd9aebd545a2f
    consul: sha256=0942ef6ed43522adfb4cddbefea2f0e64306318afb8aeab3727563f0caef04be
    consul-esm: sha256=50d9367be90f542f659bbba9d8ec3510516d995dbb2f522c8618ae75fff31757
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=9e999cfbfdc47e67d3d91e6e4edbecaa3d7c3b026307b18c0485b64d15e5083a
    nomad: sha256=e042b0f6f6648b149be7cfddac832214cf8ca17725e5f0e420b5b0547532bdcd
    nomad-autoscaler: sha256=4b89c4d266663c9795b32930199c489a67606ac13f03e7fca8da15a0513a6ca7
    nomad-driver-podman: sha256=5b9ac89585d7359f941a2504b11d50866f67c2887cb3716fba2bbaa0749a14a8
    nomad-pack: sha256=08e213dfe76152b512da9fd8c57c24365812a43c96deda6f88cde26aab03310b
    terraform: sha256=ac21c2b9dcd115711f540cbd27ead0596bb4288a917cb56dfa9b25edb3eb6280
    vault: sha256=c945e90979a7b6e4b4846285587c35b25f8191f9f70cb879132bc118ae42c368
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
