# duplicity backup

duplicity:
    pkg.installed:
        - pkgs:
            - duplicity
            - python-paramiko
            - python-boto
        - install_recommends: False


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
duplicity-cron:
    file.managed:
        - name: /etc/cron.hourly/duplicity-backup.sh
        - source: salt://duplicity/cron/duplicity-backup.jinja.sh
        - template: jinja
        - context:
            backup_folders: {{pillar['duplicity-backup'].get('backup-folders', [])}}
            backup_target_url: {{pillar['duplicity-backup']['backup-target']}}
            gpg_key_id: {{pillar['duplicity-backup']['gpg-key-id']}}
{% endif %}
