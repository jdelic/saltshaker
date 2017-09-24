# configuration pillar for duplicity backup

duplicity-backup:
    enabled: False

    # the key id for which backups will be encrypted
    gpg-key-id: 1234567

    # when NOT using the managed keyring, you will want to use --trusted-key with the long
    # key id here, unless the key has a set trust relationship
    # gpg-options: --trusted-key={{'23FC12D75291ED448C0728C877C339AB7CDC4589'[-16:]}}

    # replace when enabled, this requires a path (/backup), otherwise duplicity crashes!
    backup-target: sftp://test@host/backup

    # set to a dict of environment variables to be set in the script. This is useful to pass
    # additional configuration to duplicity, like AWS credentials
    envvars: {}
        # set GNUPGHOME if you DON'T want to use the Salt-managed keyring (crypto.gpg)
        # which is the default
        # GNUPGHOME:
