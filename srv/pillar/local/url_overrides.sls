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
    acme: http://fileserver.maurusnet.test/downloads/acmesh/3.1.6.zip
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse-8.3.3-linux-amd64.tgz
    concourse-fly: http://fileserver.maurusnet.test/downloads/concourse/fly-8.3.3-linux-amd64.tgz
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_2.1.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.43.1_linux_amd64.zip
    envoy: http://fileserver.maurusnet.test/downloads/envoy/envoy-1.40.2-linux-x86_64
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_2.1.1_linux_amd64.zip
    nomad-autoscaler: http://fileserver.maurusnet.test/downloads/nomad-autoscaler/nomad-autoscaler_0.6.0_linux_amd64.zip
    nomad-cni: http://fileserver.maurusnet.test/downloads/nomad-cni/cni-plugins-linux-amd64-v1.9.1.tgz
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_2.2.1_linux_amd64.zip
    vault-gpg-plugin: http://fileserver.maurusnet.test/downloads/vault-gpg-plugin/linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.2.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    acme: sha256=5b4045b6759cba44eb909f214c768f6ebdc4de149cfc8206dda6fa486f2e108d
    concourse: sha256=6b7699a3d3d1066b15011833dfb2712af5ca94b1f49090d035596f1c5fa82ba8
    concourse-fly: sha256=e689fdc1209463410fafe7093a74769dc2a7965c995307e11253a037813f742c
    consul: sha256=a9c9cdf1ed93bd29a9671b02e5433131f3f777bab16c076fcef712a2820bfe33
    consul-template: sha256=4f3afadcc6612abf55ae7c9c3328955bfeb43becffe15d2972acf0e0a194c339
    envoy: sha256=1d64506e25c1844f146162ddb2ece7010fa4e784faddb40a079021491f1f03cc
    nomad: sha256=073084f7690fdaea756ff1eff8b669b25c3a6c17778f19ae0c47606973ed3f39
    nomad-autoscaler: sha256=1d404b456a36a477a8c8cf26de2f79c1ad13510d0b241036f056e0675addeb15
    nomad-cni: sha256=b98f74a0f8522f0a83867178729c1aa70f2158f90c45a2ca8fa791db1c76b303
    vault: sha256=079435de8ff146bdec4cdbe3be71d672ef4e59e4df6af0f2dba672e71be21a68
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=1fd74ccfe4de134dcc527771c9eaaa2f95756975c11baff136eecdbe56bd0e1d
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
