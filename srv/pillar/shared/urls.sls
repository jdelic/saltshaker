# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    buster: deb http://ftp-stud.hs-esslingen.de/debian/ buster main contrib
    buster-backports: deb http://ftp-stud.hs-esslingen.de/debian/ buster-backports main
    buster-security: deb http://security.debian.org/debian-security buster/updates main
    buster-updates: deb http://ftp-stud.hs-esslingen.de/debian/ buster-updates main
    docker: deb https://download.docker.com/linux/debian buster stable
    envoy: deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb buster stable
    haproxy: deb http://haproxy.debian.net buster-backports-2.1 main
    maurusnet-apps: deb http://repo.maurus.net/nightly/buster/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/buster/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main


#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v6.3.0/concourse-6.3.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v6.3.0/fly-6.3.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.3.3/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.25.0/consul-template_0.25.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.12.0/nomad_0.12.0_linux_amd64.zip
    nomad-autoscaler: https://releases.hashicorp.com/nomad-autoscaler/0.1.0/nomad-autoscaler_0.1.0_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.4.3/vault_1.4.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.2.4/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.6/vault-ssh-helper_0.1.6_linux_amd64.zip


hashes:
    concourse: sha256=7179ad40fe0c330de65d019f90c4a946fb07efb19c7af69edd71e5de5eb7d961
    concourse-fly: sha256=743c386ab77b3c7fe509b394e3c1ef5c2c0041261e2f696f78f4b4fb674405e3
    consul: sha256=98df3e0a8ede84794fa4d20b1b6b5d52ad3b983dec916c4d612cecba7c48a421
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=496da8d30242ab2804e17ef2fa41aeabd07fd90176986dff58bce1114638bb71
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=065b41e39cf24e4b6bea49566b505c9b6cdaddb5fcbc7688377d89ed59078cc7
    nomad-autoscaler: sha256=a3aa8491526a9de4bb0b95c52720ece2d51cdf8fa72194cc96e817fdb565d458
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=be99da1439a60942b8d23f63eba1ea05ff42160744116e84f46fc24f1a8011b6
    vault: sha256=f486da4f6d08e42eb2c17e95cf36cc7f9d9c0e7cc8ced06ce3fca7c3abd7db3d
    vault-gpg-plugin: sha256=d6ebf6457a7ccf3294c557d4b33b7ded66d74feb761e3e056ddced1fdaed4fba
    vault-ssh-helper: sha256=3c472b42ba42584585340e51f1ce226617d616bf711e3a21a9adce4f034adebb
