# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    docker: deb http://fileserver.maurusnet.test/repo/ debian-jessie main
    jenkins: deb http://fileserver.maurusnet.test/jenkins/ jenkins main
    jessie: deb http://fileserver.maurusnet.test/debian/ jessie main
    jessie-backports: deb http://fileserver.maurusnet.test/debian/ jessie-backports main
    jessie-security: deb http://fileserver.maurusnet.test/debian/security/ jessie-updates main
    jessie-updates: deb http://fileserver.maurusnet.test/debian/ jessie-updates main
    stretch-testing: deb http://fileserver.maurusnet.test/debian/ stretch main
    saltstack: deb http://fileserver.maurusnet.test/apt/debian/8/amd64/latest jessie main
    sogo: deb http://fileserver.maurusnet.test/sogo/ jessie jessie

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key

urls:
    consul: http://fileserver.maurusnet.test/downloads/consul/consul_0.6.4_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul-template_0.15.0_linux_amd64.zip
    consul-webui: http://fileserver.maurusnet.test/downloads/consul/consul_0.6.4_web_ui.zip
    djbdns: http://fileserver.maurusnet.test/downloads/djbdns/djbdns-1.05.tar.gz
    nomad: http://fileserver.maurusnet.test/downloads/nomad/nomad_0.3.2_linux_amd64.zip
    qmail: http://fileserver.maurusnet.test/downloads/qmail/qmail-1.03.tar.gz
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.6.0_linux_amd64.zip
    fpmdeps: http://fileserver.maurusnet.test/downloads/ruby/fpm+deps.zip

hashes:
    consul: sha256=abdf0e1856292468e2c9971420d73b805e93888e006c76324ae39416edcf0627
    consul-template: sha256=b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a
    consul-webui: sha256sum=5f8841b51e0e3e2eb1f1dc66a47310ae42b0448e77df14c83bb49e0e0d5fa4b7
    djbdns: sha256=3ccd826a02f3cde39be088e1fc6aed9fd57756b8f970de5dc99fcd2d92536b48
    nomad: sha256sum=710ff3515bc449bc2a06652464f4af55f1b76f63c77a9048bc30d6fde284b441
    qmail: sha256=21ed6c562cbb55092a66197c35c8222b84115d1acab0854fdb1ad1f301626f88
    vault: sha256=283b4f591da8a4bf92067bf9ff5b70249f20705cc963bea96ecaf032911f27c2
    fpmdeps: sha256=0c0aeee1f982c9fd83abc8efd2cd09d8919bbc9be3c0702aa7673cf9be4bf5be
