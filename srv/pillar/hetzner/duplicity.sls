# configuration pillar for duplicity backup

duplicity-backup:
    enabled: True
    gpg-key-id: 7CDC4589
    filename: /etc/cron.hourly/duplicity-backup.sh  # use this to reference accumulators
    # backup-target is set in shared.secrets.live-backup
    envvars: {}
