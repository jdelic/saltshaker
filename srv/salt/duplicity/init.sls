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


{% set envvars = pillar['duplicity-backup'].get('envvars', {}) %}
{% if 'GNUPGHOME' not in envvars %}
    {% set x = envvars.__setitem__('GNUPGHOME', pillar['gpg']['shared-keyring-location']) %}
{% endif %}

{% set gpg_keys = pillar['duplicity-backup']['gpg-keys'] %}
{% if pillar['duplicity-backup'].get('encrypt-for-host', False) %}
    {% set x = gpg_keys.append(grains['id']) %}
{% endif %}

duplicity-cron-backup-script:
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
            gpg_keys: {{pillar['duplicity-backup']['gpg-keys']|tojson}}
            gpg_options: {{pillar['duplicity-backup'].get('gpg-options', '')}}
            envvars: {{envvars|tojson}}


duplicity-cron-cleanup-script:
    file.managed:
        - name: /etc/duplicity.d/cleanup.sh
        - source: salt://duplicity/cron/cleanup.jinja.sh
        - template: jinja
        - user: root
        - group: root
        - mode: '0700'
        - context:
            backup_target_url: {{pillar['duplicity-backup']['backup-target']}}
            cron_enabled: {{pillar.get('duplicity-backup', {}).get('enable-cleanup-cron', False)}}
            cleanup_mode: {{pillar.get('duplicity-backup', {}).get('cleanup-mode', 'remove-older-than')}}
            cleanup_selector: {{pillar.get('duplicity-backup', {}).get('cleanup-selector', '1y')}}
            envvars: {{envvars|tojson}}


{% for crontype in ['hourly', 'daily'] %}
    {% for folder in ['prescripts', 'postscripts', 'folderlinks'] %}
duplicity-config-{{crontype}}-{{loop.index}}:
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
        - source: salt://duplicity/cron/crontab.jinja
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            cleanup_enabled: {{pillar.get('duplicity-backup', {}).get('enable-cleanup-cron', False)}}
            cleanup_schedule: {{pillar.get('duplicity-backup', {}).get('cleanup-cron-schedule', '0 10 1 * *')}}
{% endif %}
