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
    concourse: https://github.com/concourse/concourse/releases/download/v8.2.2/concourse-8.2.2-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v8.2.2/fly-8.2.2-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/2.0.0/consul_2.0.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.42.0/consul-template_0.42.0_linux_amd64.zip
    envoy: https://github.com/envoyproxy/envoy/releases/download/v1.38.0/envoy-1.38.0-linux-x86_64
    nomad: https://releases.hashicorp.com/nomad/2.0.2/nomad_2.0.2_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.5.0/nomad-autoscaler_0.5.0_linux_amd64.zip
    nomad-cni: https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz
    vault: https://releases.hashicorp.com/vault/2.0.1/vault_2.0.1_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.6.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip


hashes:
    acme: sha256=0bff3addd5c01489c116064f053ae8a4baf33fe61ea456bdfd0939a3c378ac53
    concourse: sha256=6807298891dc0ad0843099ea367aef9cbf6e1c268c7675f7ca635911250483d6
    concourse-fly: sha256=ca30047d59c556d14d01b9bea04d7bd46972e60134dc972523513aacf24d3936
    consul: sha256=25fe76d3203529af59834cff4a29a128050b630d62901be7ad850b9991ddf991
    consul-template: sha256=94d5044b822c5219bb116916b8d4d2545630e6ce0e1639ddd25309a26cf62ff2
    envoy: sha256=cca312a7c3f91852f2849995c895130c59842e21ba787dc90bafa4026d6c5ecc
    nomad: sha256=694bbbcec397f994299f1a52fe4b1d9276e08ce8a524af54226eb51b9eceddb8
    nomad-autoscaler: sha256=45ef1905a44cf24f15e08c31f437ad5df7e55996eea91b313b0f2c5654ed1030
    nomad-cni: sha256=b98f74a0f8522f0a83867178729c1aa70f2158f90c45a2ca8fa791db1c76b303
    vault: sha256=c6ed3be36a750875906916716680322719920a102f98c9a0b3105ecff63b9e34
    vault-gpg-plugin: sha256=975115ef6e870cd5429efe99cffc8ce1f8c17350d9fbab02527e4de9ff436e62
    vault-ssh-helper: sha256=fe26f62e5822bdf66ea4bf874d1a535ffca19af07a27ff3bcd7e344bc1af39fe
