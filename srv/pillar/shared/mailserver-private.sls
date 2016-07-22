
emailstore:
    path: /secure/email

filterstore:
    path: /secure/webfilter

mail-scripts:
    install-dir: /usr/local/mail

imap:
    sslcert: default  # special value "default" means: "use maincert from ssl.init"
    sslkey: default
    sslcert-contents: ""  # contents_pillar reference if imap should use a different cert
    sslkey-content: ""


smtp:
    sslcert: default  # see above
    sslcert-contents: ""
    relay-service-link: /etc/service/qmail-smtpd-relay
    relay-service-dir: /var/qmail/service/smtpd-relay
    internal-relay-service-link: /etc/service/qmail-smtpd-internal-relay
    internal-relay-service-dir: /var/qmail/service/smtpd-internal-relay
    receiver-service-link: /etc/service/qmail-smtpd-receiver
    receiver-service-dir: /var/qmail/service/smtpd-receiver

mail-delivery:
    service-link: /etc/service/qmail-delivery
    service-dir: /var/qmail/service/delivery

# vim: syntax=yaml

