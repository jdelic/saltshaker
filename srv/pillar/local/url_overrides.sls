# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/repo/ trixie stable
    haproxy: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/haproxy/ trixie-backports-3.2 main
    maurusnet: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    postgresql: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/postgresql/ trixie-pgdg
    saltstack: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/saltproject-deb/ stable main
    trixie: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/ trixie main
    trixie-backports: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/ trixie-backports main
    trixie-security: deb [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] http://fileserver.maurusnet.test/debian/security/ trixie-security main
    trixie-updates: [signed-by=/etc/apt/keyrings/maurusnet-package-archive.gpg] deb http://fileserver.maurusnet.test/debian/updates/ trixie-updates main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.1.2.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-7.14.3-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-7.14.3-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.22.2_linux_amd64.zip
    consul-esm: http://fileserver.maurusnet.test/downloads/consul-esm/consul-esm_0.9.1_linux_amd64.zip
    consul-replicate: http://fileserver.maurusnet.test/downloads/consul-replicate/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.41.3_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_1.11.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.4.9_linux_amd64.zip
    nomad-driver-podman: http://fileserver.maurusnet.test/downloads/nomad-driver-podman/nomad-driver-podman_0.6.4_linux_amd64.zip
    nomad-pack: http://fileserver.maurusnet.test/downloads/nomad-pack/nomad-pack_0.4.1_linux_amd64.zip
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_1.14.3_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_1.21.2_linux_amd64.zip
    vault-auditor: http://fileserver.maurusnet.test/downloads/vault-auditor/vault-auditor_1.0.3_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=aeb51fb15012bea28feb1bfa19bb28569f41d944fb7c064d9b49d95846db6fa4
    concourse-fly: sha256=b32f64e429e477fcfdcceb7c70a3378fee592377453106d944327cf87d78045e
    consul: sha256=e9ad339128e396238f053269bf8f76aeba1b5fada6f6cb60ab19fe70e133acde
    consul-esm: sha256=50d9367be90f542f659bbba9d8ec3510516d995dbb2f522c8618ae75fff31757
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=f708323c5a9eeedf1e125662fa1dd3c54f8cadd0758ef2a9a27c7a22e181e93c
    nomad: sha256=8e8fbc9c3ddae39a63f7ed70a99bb4b936bb6e88ed9160ce0e9d36ff2909c1f3
    nomad-autoscaler: sha256=4b89c4d266663c9795b32930199c489a67606ac13f03e7fca8da15a0513a6ca7
    nomad-driver-podman: sha256=5b9ac89585d7359f941a2504b11d50866f67c2887cb3716fba2bbaa0749a14a8
    nomad-pack: sha256=08e213dfe76152b512da9fd8c57c24365812a43c96deda6f88cde26aab03310b
    terraform: sha256=178b2a602251bb68b94732aceca2cc1023d87597cb83dba92cab31b6689edb4d
    vault: sha256=d2005a053a2ab75318d395ca8151aef9116fde67f75dc8f43a4fa9def6f3fc9e
    vault-auditor: sha256=14aebc65351e52ff705fd9a4f3fb89655bf3a87a6c67a86ff8aa67ef5ff4837f
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
