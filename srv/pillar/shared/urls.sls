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
    saltstack: deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    concourse: https://github.com/concourse/concourse/releases/download/v3.4.0/concourse_linux_amd64
    consul: https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.19.0/consul-template_0.19.0_linux_amd64.zip
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.7.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.6.0/nomad_0.6.0_linux_amd64.zip
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: https://releases.hashicorp.com/terraform/0.10.0/terraform_0.10.0_linux_amd64.zip
    vault: https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip
    vault-ssh-helper: https://releases.hashicorp.com/vault-ssh-helper/0.1.3/vault-ssh-helper_0.1.3_linux_amd64.zip


hashes:
    concourse: sha256=cd3bcd095969b89a4c806b8036ef086e4ba2e29497e651eef7ffaa80fabce484
    consul: sha256=0a2921fc7ca7e4702ef659996476310879e50aeeecb5a205adfdbe7bd8524013
    consul-template: sha256=31dda6ebc7bd7712598c6ac0337ce8fd8c533229887bd58e825757af879c5f9f
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=fcf108046164cfeda84eab1c3047e36ad59d239b66e6b2f013e6c93064bc6313
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=f991039e3822f10d6e05eabf77c9f31f3831149b52ed030775b6ec5195380999
    vault: sha256=3c4d70ba71619a43229e65c67830e30e050eab7a81ac6b28325ff707e5914188
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
