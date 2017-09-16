# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    docker: deb https://apt.dockerproject.org/repo debian-stretch main
    stretch: deb http://ftp-stud.hs-esslingen.de/debian/ stretch main contrib
    stretch-backports: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-backports main
    stretch-security: deb http://security.debian.org/ stretch/updates main
    stretch-updates: deb http://ftp-stud.hs-esslingen.de/debian/ stretch-updates main
    maurusnet-apps: deb http://repo.maurus.net/release/stretch/ mn-release main
    maurusnet-opensmtpd: deb http://repo.maurus.net/stretch/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
    saltstack: deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v3.4.1/concourse_linux_amd64
    consul: https://releases.hashicorp.com/consul/0.9.3/consul_0.9.3_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.19.2/consul-template_0.19.2_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.6.3/nomad_0.6.3_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.10.5/terraform_0.10.5_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.8.2/vault_0.8.2_linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.3/vault-ssh-helper_0.1.3_linux_amd64.zip


hashes:
    concourse: sha256=1a7385b9bed35ec93c0ed59eec1a4a08c3dd131310585ffff84530abaec0baa1
    consul: sha256=9c6d652d772478d9ff44b6decdd87d980ae7e6f0167ad0f7bd408de32482f632
    consul-template: sha256=c4bf073081a99030f45a446a11b8e9f8a4b56270b096d90b51e48f6e4416ffcc
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=908ee049bda380dc931be2c8dc905e41b58e59f68715dce896d69417381b1f4e
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=acec7133ffa00da385ca97ab015b281c6e90e99a41076ede7025a4c78425e09f
    vault: sha256=b7050bbc0b9ad554dd03040d1e5ad9c3b0cafde7e781f65433e4db5d05882245
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
