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
    maurusnet-nightly: deb http://repo.maurus.net/nightly/stretch/ mn-nightly main
    maurusnet-opensmtpd: deb http://repo.maurus.net/stretch/opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://repo.maurus.net/stretch/radicale/ mn-radicale main
    postgresql: deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
    saltstack: deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v3.1.1/concourse_linux_amd64
    consul: https://releases.hashicorp.com/consul/0.8.4/consul_0.8.4_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.18.5/consul-template_0.18.5_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.9.8/terraform_0.9.8_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.7.3/vault_0.7.3_linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.3/vault-ssh-helper_0.1.3_linux_amd64.zip


hashes:
    concourse: sha256=a4606dbff391339f8d33b1c1e13fa50eea281dde03e224f20dabbf71d50ff10c
    consul: sha256=c8859a0a34c50115cdff147f998b2b63226f5f052e50f342209142420d1c2668
    consul-template: sha256=b0cd6e821d6150c9a0166681072c12e906ed549ef4588f73ed58c9d834295cd2
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=3f5210f0bcddf04e2cc04b14a866df1614b71028863fe17bcdc8585488f8cb0c
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=f951885f4e15deb4cf66f3b199964e3e74a0298bb46c9fe42e105df2ebcf3d16
    vault: sha256=2822164d5dd347debae8b3370f73f9564a037fc18e9adcabca5907201e5aab45
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
