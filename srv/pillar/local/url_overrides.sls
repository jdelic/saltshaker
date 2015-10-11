# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://fileserver.maurusnet.test/aptly/ squeeze main
    aptly-nightly: deb http://fileserver.maurusnet.test/aptly-nightly/ nightly main
    jenkins: deb http://fileserver.maurusnet.test/jenkins/ jenkins main
    jessie: deb http://fileserver.maurusnet.test/debian/ jessie main
    jessie-backports: deb http://fileserver.maurusnet.test/debian/ jessie-backports main
    jessie-security: deb http://fileserver.maurusnet.test/debian/security/ jessie-updates main
    jessie-updates: deb http://fileserver.maurusnet.test/debian/ jessie-updates main
    saltstack: deb http://fileserver.maurusnet.test/saltstack/ jessie contrib
    sogo: deb http://fileserver.maurusnet.test/sogo/ jessie jessie

    pgpkey: salt://mn/fileserver_ACADBD6B.pgp.key

urls:
    consul: http://fileserver.maurusnet.test/downloads/consul/0.5.2_linux_amd64.zip
    consul-template: http://fileserver.maurusnet.test/downloads/consul-template/consul_template_0.11.0_linux_amd64.zip
    consul-webui: http://fileserver.maurusnet.test/downloads/consul/0.5.2_web_ui.zip
    djbdns: http://fileserver.maurusnet.test/downloads/djbdns/djbdns-1.05.tar.gz
    qmail: http://fileserver.maurusnet.test/downloads/qmail/qmail-1.03.tar.gz
    vault: http://fileserver.maurusnet.test/downloads/vault/vault_0.2.0_linux_amd64.zip
    nomad: http://fileserver.maurusnet.test/downloads/nomad/v0.1.2.zip
