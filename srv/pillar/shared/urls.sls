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
    concourse: https://github.com/concourse/concourse/releases/download/v8.3.3/concourse-8.3.3-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v8.3.3/fly-8.3.3-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/2.1.0/consul_2.1.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.43.1/consul-template_0.43.1_linux_amd64.zip
    envoy: https://github.com/envoyproxy/envoy/releases/download/v1.40.2/envoy-1.40.2-linux-x86_64
    nomad: https://releases.hashicorp.com/nomad/2.1.1/nomad_2.1.1_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.6.0/nomad-autoscaler_0.6.0_linux_amd64.zip
    nomad-cni: https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz
    vault: https://releases.hashicorp.com/vault/2.2.1/vault_2.2.1_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.4/vault-ssh-helper_0.2.4_linux_amd64.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
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
