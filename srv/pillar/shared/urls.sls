# This is a collection of URLs that different states use to download packages /
# archives / other things. They are here so that they can be easily overridden,
# for example in local.url_overrides for a local development file server/debian
# mirror if you have such a thing

repos:
    aptly: deb http://repo.aptly.info/ squeeze main
    aptly-nightly: deb http://repo.aptly.info/ nightly main
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
    consul-template: https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip
    consul-webui: https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_web_ui.zip
    djbdns: http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
    nomad: https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip
    qmail: http://cr.yp.to/software/qmail-1.03.tar.gz
    vault: https://releases.hashicorp.com/vault/0.5.2/vault_0.5.2_linux_amd64.zip
