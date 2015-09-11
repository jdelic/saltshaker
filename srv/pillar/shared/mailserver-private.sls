
emailstore:
    path: /secure/email

filterstore:
    path: /secure/webfilter

mail-scripts:
    install-dir: /usr/local/mail

imap:
    sslcert: /etc/ssl/local/dovecot.crt
    sslkey: /etc/ssl/private/dovecot.key

smtp:
    sslcert: /etc/ssl/private/qmail.combined.crt
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

