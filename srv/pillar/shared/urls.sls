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
    maurusnet-apps: deb http://repo.maurus.net/nightly/buster/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/buster/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main
    saltstack: deb http://repo.saltstack.com/py3/debian/10/amd64/latest buster main
    haproxy: deb http://haproxy.debian.net buster-backports-2.0 main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v5.6.0/concourse-5.6.0-linux-amd64.tgz
    concourse-fly: https://github.com/concourse/concourse/releases/download/v5.6.0/fly-5.6.0-linux-amd64.tgz
    consul: https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
    consul-esm: https://releases.hashicorp.com/consul-esm/0.3.3/consul-esm_0.3.3_linux_amd64.zip
    consul-replicate: https://releases.hashicorp.com/consul-replicate/0.4.0/consul-replicate_0.4.0_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.22.0/consul-template_0.22.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.10.0/nomad_0.10.0_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip
    vault-gpg-plugin: https://github.com/LeSuisse/vault-gpg-plugin/releases/download/v0.2.3/linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.4/vault-ssh-helper_0.1.4_linux_amd64.zip


hashes:
    concourse: sha256=c11d206ef546b45e656e75433d6aa0e57607ab5af4d76f955dc2d15e53218e22
    concourse-fly: sha256=addf3a1fb8e888336310a918553578284c3a444bfba9fc369b526c00c62e2628
    consul: sha256=a8568ca7b6797030b2c32615b4786d4cc75ce7aee2ed9025996fe92b07b31f7e
    consul-esm: sha256=1553c59d0f93a467d8cf15135a5314f8058e8ca849b305c211dd9b9aaafbbf13
    consul-replicate: sha256=96c6651291c2f8e75d98d04b9b4653d8a02324edaa25783744d9ea1d8d411c61
    consul-template: sha256=5a1e7e7b35ea0c24116b14ae61e11a462eeeb75fc518d76c80894c245b9791ef
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=dd9dbe334e36e15c6f659c52d2722743f6632674fc9ffb42774378eb8ee1747f
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=67bc7a49c0946ad48b14cc6e95482fdd3e7e9f7dc6811f4ce6ff531fc565bd3a
    vault: sha256=fe15676404aff35cb45f7c957f90491921b9269d79a8f933c5a36e26a431bfc4
    vault-gpg-plugin: sha256=5138feed5323badcea50e9fa1b6a16392509341703efbec7b2e1daa41f453da6
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
