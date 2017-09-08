# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb http://fileserver.maurusnet.test/repo/ debian-stretch main
    stretch: deb http://fileserver.maurusnet.test/debian/ stretch main
    stretch-backports: deb http://fileserver.maurusnet.test/debian/ stretch-backports main
    stretch-security: deb http://fileserver.maurusnet.test/debian/security/ stretch-updates main
    stretch-updates: deb http://fileserver.maurusnet.test/debian/ stretch-updates main
    maurusnet-nightly: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ stretch-pgdg main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/9/amd64/latest stretch main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.9.2_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.19.2_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.6.2_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.10.3_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.8.2_linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.3_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=1a7385b9bed35ec93c0ed59eec1a4a08c3dd131310585ffff84530abaec0baa1
    consul: sha256=0a2921fc7ca7e4702ef659996476310879e50aeeecb5a205adfdbe7bd8524013
    consul-template: sha256=c4bf073081a99030f45a446a11b8e9f8a4b56270b096d90b51e48f6e4416ffcc
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=da1f1e8abf18b3d351375a6341d5fc306caad00323218a90f195021e7172b0f8
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=f316c6ff8b2abe257250d19cbe0e3cf745dedfa67b37bb4afaf95e0291efeade
    vault: sha256=b7050bbc0b9ad554dd03040d1e5ad9c3b0cafde7e781f65433e4db5d05882245
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
    fpmdeps: sha256=121445fb992c88d4b73ed0736aa4e6e1fb67696b73de9fb4b82e33b1f09b02ad
