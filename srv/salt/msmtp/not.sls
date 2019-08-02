# remove msmtp. This is assigned to future mailservers.

msmtp:
    pkg.purged


/etc/msmtprc:
    file.absent
