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
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-8.3.1-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-8.3.1-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_2.0.4_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.43.0_linux_amd64.zip
    envoy: http://fileserver.maurusnet.test/downloads/envoy/envoy-1.39.0-linux-x86_64
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_2.0.7_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.5.0_linux_amd64.zip
    nomad-cni: http://fileserver.maurusnet.test/downloads/nomad-cni/cni-plugins-linux-amd64-v1.9.1.tgz
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_2.1.1_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.1_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=1b724bbef518ab882ec415567ecb9201a4d8d5f0fcb880994c98b395985c3682
    concourse-fly: sha256=16efe4b0945d936b7669147b5beef4140c7e22b990d3776ddc08d63225c243e1
    consul: sha256=7a28033850a24fd411722593931625d8b548a27646c3ab70c1379ea7fd2af423
    consul-template: sha256=aa49f009a708f3e3beea990aa29cfaecfe6925c0b17ca9201747e1469922264e
    envoy: sha256=4409dadc87931d8f8676314cbd83071cb65125fb4feac3f6335800580dfa9218
    nomad: sha256=4c9b8a0850d6fd9caadbbab09b3e6fdf8b77aa777729543c70c61b85acca68c1
    nomad-autoscaler: sha256=45ef1905a44cf24f15e08c31f437ad5df7e55996eea91b313b0f2c5654ed1030
    nomad-cni: sha256=b98f74a0f8522f0a83867178729c1aa70f2158f90c45a2ca8fa791db1c76b303
    vault: sha256=8aa90f9cea46f541fc7baa3d0ec692fc06afde9a248cc1f2dcac46a567c6f56b
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
