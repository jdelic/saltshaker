# configuration pillar for duplicity backup

duplicity-backup:
    enabled: True
    encrypt-for-host: True
    gpg-keys:
        - 7CDC4589
    additional-options: --full-if-older-than 1M
    # enable-cleanup will run an additional cron job at the first of every month
    # removing backups older than a certain time (unless newer backups depend on them)
    enable-cleanup-cron: True
    cleanup-cron-schedule: 0 10 1 * *
    cleanup-mode: remove-older-than
    cleanup-selector: 6M
    # backup-target is set in shared.secrets.live-backup
