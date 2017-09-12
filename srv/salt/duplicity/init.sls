# duplicity backup

duplicity:
    pkg.installed


duplicity-cron:
    file.managed:
        - name: /etc/cron.hourly/duplicity-backup.sh
        - source: salt://duplicity/cron/duplicity-backup.jinja.sh
        - template: jinja
        - context:
            backup_folders: {{pillar['duplicity-backup'].get('backup-folders', [])}}
            backup_target_url: {{pillar['duplicity-backup']['backup-target']}}
            backup_target_append_minion_id: {{pillar['duplicity-backup'].get('append-minion-id', True)}}
            gpg_key_id: {{pillar['duplicity-backup']['gpg-key-id']}}
