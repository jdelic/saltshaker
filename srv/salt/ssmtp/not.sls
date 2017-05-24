# remove ssmtp. This is assigned to future mailservers.

ssmtp:
    pkg.purged


/etc/ssmtp:
    file.absent
