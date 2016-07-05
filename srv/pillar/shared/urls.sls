# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
    docker: deb https://apt.dockerproject.org/repo debian-jessie main
    jenkins: deb http://pkg.jenkins-ci.org/debian binary/
    jessie: deb http://ftp-stud.hs-esslingen.de/debian/ jessie main contrib
    jessie-backports: deb http://ftp-stud.hs-esslingen.de/debian/ jessie-backports main
    jessie-security: deb http://security.debian.org/ jessie/updates main
    jessie-updates: deb http://ftp-stud.hs-esslingen.de/debian/ jessie-updates main
    stretch-testing: deb http://ftp-stud.hs-esslingen.de/debian/ stretch main
    saltstack: deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main
    sogo: deb http://inverse.ca/debian-v3 jessie jessie

#   pgpkey: Set this to a salt:// url if you need to deploy your own repo signing key
#           If you need to deploy more than one key, you should really write your own
#           state for that!

urls:
    consul: https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
    consul-template: https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_linux_amd64.zip
    consul-webui: https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_web_ui.zip
    djbdns: http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
    exxo: https://bintray.com/artifact/download/mbachry/exxo/exxo-0.0.5.tar.xz
    nomad: https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip
    pyrun34: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.4_ucs4-linux-x86_64.tgz
    pyrun35: https://downloads.egenix.com/python/egenix-pyrun-2.2.1-py3.5_ucs4-linux-x86_64.tgz
    qmail: http://cr.yp.to/software/qmail-1.03.tar.gz
    vault: https://releases.hashicorp.com/vault/0.6.0/vault_0.6.0_linux_amd64.zip


hashes:
    consul: sha256=abdf0e1856292468e2c9971420d73b805e93888e006c76324ae39416edcf0627
    consul-template: sha256=b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a
    consul-webui: sha256sum=5f8841b51e0e3e2eb1f1dc66a47310ae42b0448e77df14c83bb49e0e0d5fa4b7
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    exxo: sha256=3c8e7a9cbe2f88b7c67d4e970f60de7f63a9ce4206aaf214326ead49cc5a2396
    nomad: sha256sum=710ff3515bc449bc2a06652464f4af55f1b76f63c77a9048bc30d6fde284b441
    pyrun34: sha256sum=9798f3cd00bb39ee07daddb253665f4e3777ab58ffb6b1d824e206d338017e71
    pyrun35: sha256sum=d20bd23b3e6485c0122d4752fb713f30229e7c522e4482cc9716afc05413b02e
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    vault: sha256=283b4f591da8a4bf92067bf9ff5b70249f20705cc963bea96ecaf032911f27c2
