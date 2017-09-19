# configuration pillar for duplicity backup

duplicity-backup:
    enabled: False
    gpg-key-id: 7CDC4589
    filename: /etc/cron.hourly/duplicity-backup.sh  # use this to reference accumulators
    backup-target: sftp://user@host/path  # replace when enabled
    backup-folders: []
