# configuration pillar for duplicity backup

duplicity-backup:
    enabled: False
    gpg-key-id: 7CDC4589
    backup-target: sftp://user@host/path
    backup-folders: []
