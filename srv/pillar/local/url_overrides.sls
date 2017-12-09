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
    maurusnet-apps: deb http://fileserver.maurusnet.test/mn-nightly/ mn-nightly main
    maurusnet-opensmtpd: deb http://fileserver.maurusnet.test/mn-opensmtpd/ mn-opensmtpd main
    maurusnet-radicale: deb http://fileserver.maurusnet.test/mn-radicale/ mn-radicale main
    postgresql: deb http://fileserver.maurusnet.test/postgresql/ stretch-pgdg main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/9/amd64/latest stretch main

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key


urls:
    concourse: http://fileserver.maurusnet.test/downloads/concourse/concourse_linux_amd64
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_1.0.1_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.19.4_linux_amd64.zip
    exxo: http://fileserver.maurusnet.test/downloads/exxo/exxo-0.0.7.tar.xz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.7.0_linux_amd64.zip
    pyrun35: http://fileserver.maurusnet.test/downloads/exxo/egenix-pyrun-2.2.3-py3.5_ucs4-linux-x86_64.tgz
    terraform: http://fileserver.maurusnet.test/downloads/terraform/terraform_0.11.1_linux_amd64.zip
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.9.0_linux_amd64.zip
    vault-ssh-helper: http://fileserver.maurusnet.test/downloads/vault/vault-ssh-helper_0.1.4_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip


hashes:
    concourse: sha256=05a6f9882a87a41bfa8ef27ba025b3b6b3c2fb2c56357263656bec8151f4bfe4
    consul: sha256=eac5755a1d19e4b93f6ce30caaf7b3bd8add4557b143890b1c07f5614a667a68
    consul-template: sha256=5f70a7fb626ea8c332487c491924e0a2d594637de709e5b430ecffc83088abc0
    exxo: sha256=ce3d6ae10d364c5a0726cce127602fe6fa5d042b11afd21d79502f8216b42e1e
    nomad: sha256=b3b78dccbdbd54ddc7a5ffdad29bce2d745cac93ea9e45f94e078f57b756f511
    pyrun35: sha256=8bf8b374f582bb53600dd846a0cdb38e18586bbda06261321d48df69ddbf730e
    terraform: sha256=4e3d5e4c6a267e31e9f95d4c1b00f5a7be5a319698f0370825b459cb786e2f35
    vault: sha256=801ce0ceaab4d2e59dbb35ea5191cfe8e6f36bb91500e86bec2d154172de59a4
    vault-ssh-helper: sha256=156ce8250725e64a3e4dc51018a18813dd44d1f2a6c853976bc20e1625d631a1
    fpmdeps: sha256=acddcc12840c6684631d30b32c314a8f73d9319f69c26411ad90a7aa70b0a1df
