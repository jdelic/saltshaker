# configuration pillar for duplicity backup

duplicity-backup:
    enabled: False

    # if vault-create-perhost-key is True then duplicity can use the
    # host's key to encrypt and for management purposes. Since all the
    # data is already on the host, this should be fine in terms of
    # security.
    encrypt-for-host: True
    # the key id for which backups will be encrypted
    gpg-keys:
        - 1234567
        # ...

    # when NOT using the managed keyring, you will want to use --trusted-key with the long
    # key id here, unless the key has a set trust relationship
    # gpg-options: --trusted-key={{'23FC12D75291ED448C0728C877C339AB7CDC4589'[-16:]}}

    # replace when enabled, this requires a path (/backup), otherwise duplicity crashes!
    backup-target: sftp://test@host/backup

    # set additional options. For example, to make a full backup every month.
    additional-options: --full-if-older-than 1M

    # enable-cleanup will run an additional cron job at the first of every month
    # removing backups older than a certain time (unless newer backups depend on them)
    enable-cleanup-cron: False
    # example: run on the first of every month
    cleanup-cron-schedule: 0 10 1 * *
    # example: remove backups older than a certain time. See duplicity man page for others (like remove-all-but-n-full)
    cleanup-mode: remove-older-than
    # example: delete all backups older than a year
    cleanup-selector: 1y

    # set to a dict of environment variables to be set in the script. This is useful to pass
    # additional configuration to duplicity, like AWS credentials
    envvars: {}
        # set GNUPGHOME if you DON'T want to use the Salt-managed keyring (crypto.gpg)
        # which is the default
        # GNUPGHOME:
        # set FTP_PASSWORD for backends that require a password so that it doesn't have
        # to be part of the URL (which might be shown in cronjob output)
        # FTP_PASSWORD:
