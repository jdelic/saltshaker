# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/repo/ trixie stable
    haproxy: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/haproxy/ trixie-backports-3.2 main
    maurusnet: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/mn-release/ mn-release main
    postgresql: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/postgresql/ trixie-pgdg
    saltstack: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/saltproject-deb/ stable main
    trixie: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/ trixie main
    trixie-backports: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/ trixie-backports main
    trixie-security: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/security/ trixie-security main
    trixie-updates: [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] deb http://fileserver.maurusnet.test/debian/updates/ trixie-updates main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.1.2.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-8.1.0-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-8.1.0-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.22.5_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.41.4_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.11.2_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.9_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.21.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=aeaab9a47db011b0cc8720b77158948044e7580c2168bc957268473cf6112817
    concourse-fly: sha256=e8ef5afa9789e149a7bcf76921a063a5414bf8239ac3ae62cb880f03f40b862c
    consul: sha256=58603b87fd085282f882fcd02b5165c93b321692514b2ab822dec8dd4cd028a3
    consul-template: sha256=9e999cfbfdc47e67d3d91e6e4edbecaa3d7c3b026307b18c0485b64d15e5083a
    nomad: sha256=e042b0f6f6648b149be7cfddac832214cf8ca17725e5f0e420b5b0547532bdcd
    nomad-autoscaler: sha256=4b89c4d266663c9795b32930199c489a67606ac13f03e7fca8da15a0513a6ca7
    nomad-pack: sha256=08e213dfe76152b512da9fd8c57c24365812a43c96deda6f88cde26aab03310b
    vault: sha256=c945e90979a7b6e4b4846285587c35b25f8191f9f70cb879132bc118ae42c368
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
