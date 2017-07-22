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
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/8/amd64/latest jessie main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.9.0_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.19.0_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.5.6_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.9.11_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.7.3_linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.3_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=ccaba564b04e70eeb9836afcd20b067154c3804090cc8aa93c1d4195c8150b0e
    consul: sha256=33e54c7d9a93a8ce90fc87f74c7f787068b7a62092b7c55a945eea9939e8577f
    consul-template: sha256=31dda6ebc7bd7712598c6ac0337ce8fd8c533229887bd58e825757af879c5f9f
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=3f5210f0bcddf04e2cc04b14a866df1614b71028863fe17bcdc8585488f8cb0c
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=804d31cfa5fee5c2b1bff7816b64f0e26b1d766ac347c67091adccc2626e16f3
    vault: sha256=2822164d5dd347debae8b3370f73f9564a037fc18e9adcabca5907201e5aab45
    vault-ssh-helper: sha256=212eb6f98cfc28f201e4dc3106a1bfb82799eacb31e4b380e7c17a0457732cc0
    fpmdeps: sha256=121445fb992c88d4b73ed0736aa4e6e1fb67696b73de9fb4b82e33b1f09b02ad
