# configuration pillar for duplicity backup

duplicity-backup:
    enabled: False
    gpg-key-id: 7CDC4589
    backup-target: sftp://user@host/path  # replace when enabled
    # set to a dict of environment variables to be set in the script. This is useful to pass
    # additional configuration to duplicity, like AWS credentials
    envvars: {}
