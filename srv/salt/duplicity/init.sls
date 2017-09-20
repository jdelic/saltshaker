# duplicity backup

duplicity:
    pkg.installed:
        - pkgs:
            - duplicity
            - python-paramiko
            - python-boto
        - install_recommends: False


duplicity-cron-config-folder:
    file.directory:
        - name: /etc/duplicity.d
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


duplicity-cron-script:
    file.managed:
        - name: /etc/duplicity.d/backup.sh
        - source: salt://duplicity/cron/backup.jinja.sh
        - template: jinja
        - user: root
        - group: root
        - mode: '0700'
        - context:
            additional_options: {{pillar['duplicity-backup'].get('additional-options', '')}}
            backup_target_url: {{pillar['duplicity-backup']['backup-target']}}
            gpg_key_id: {{pillar['duplicity-backup']['gpg-key-id']}}
            gpg_options: {{pillar['duplicity-backup'].get('gpg-options', '')}}
            envvars: {{pillar['duplicity-backup'].get('envvars', {})}}


{% for crontype in ['hourly', 'daily'] %}
    {% for ix, folder in enumerate(['prescripts', 'postscripts', 'folderlinks']) %}
duplicity-config-{{crontype}}-{{ix}}:
    file.directory:
        - name: /etc/duplicity.d/{{crontype}}/{{folder}}
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
        - require:
            - file: duplicity-cron-config-folder
    {% endfor %}
{% endfor %}


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
duplicity-crontab:
    file.managed:
        - name: /etc/cron.d/duplicity
        - source: salt://duplicity/cron/crontab
        - user: root
        - group: root
        - mode: '0755'
{% endif %}
