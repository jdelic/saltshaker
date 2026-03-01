# duplicity backup

duplicity:
    pkg.installed:
        - pkgs:
            - duplicity
            - python3-paramiko
            - python3-botocore
        - install_recommends: False


duplicity-cron-config-folder:
    file.directory:
        - name: /etc/duplicity.d
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
    {% set envvars = pillar['duplicity-backup'].get('envvars', {}) %}
    {% if 'GNUPGHOME' not in envvars %}
        {% set envvars = envvars | set_dict_key_value('GNUPGHOME', pillar['gpg']['shared-keyring-location']) %}
    {% endif %}
    {% if 'FTP_PASSWORD' not in envvars %}
        {% set envvars = envvars | set_dict_key_value('FTP_PASSWORD', grains['envdir']['backup_password']) %}
    {% endif %}

    {# the following makes sure that the host gpg key comes first, as it has no passphrase #}
    {% set gpg_keys = [] %}
    {% if pillar['gpg'].get('vault-create-perhost-key', False) %}
        {% set host_key = salt['cmd.run_stdout'](
            "gpg --no-default-keyring --homedir {gpghomedir} --list-keys --with-colons {hostname} | grep -B 1 fpr | "
            "grep -A 1 pub | grep fpr | cut -d':' -f 10".format(
                gpghomedir=pillar['gpg']['shared-keyring-location'],
                hostname=grains['id']), python_shell=True) %}
    {% endif %}
    {% if pillar['duplicity-backup'].get('encrypt-for-host', False) and pillar['gpg'].get('vault-create-perhost-key', False) %}
        {% set x = gpg_keys.append(host_key) %}
    {% endif %}
    {% for gpg_key in pillar['duplicity-backup']['gpg-keys'] %}
        {% set x = gpg_keys.append(gpg_key) %}
    {% endfor %}

    {% set backup_target_url = "sftp://{username}@{host}{sep}{path}".format(username=grains['envdir']['backup_username'],
                                                                       host=grains['envdir']['backup_server'],
                                                                       sep='/' if not grains['envdir']['backup_homedir'].startswith('/') else '',
                                                                       path=grains['envdir']['backup_homedir']) %}
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
            sign_key: {{host_key if pillar['gpg'].get('vault-create-perhost-key', False) else ''}}
            backup_target_url: {{backup_target_url}}
            gpg_keys: {{gpg_keys|tojson}}
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
            backup_target_url: {{backup_target_url}}
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


duplicity-crontab:
    file.managed:
        - name: /etc/cron.d/duplicity
        - source: salt://duplicity/cron/crontab.jinja
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            duplicity_enabled: {{pillar.get('duplicity-backup', {}).get('enabled', False)}}
            cleanup_enabled: {{pillar.get('duplicity-backup', {}).get('enable-cleanup-cron', False)}}
            cleanup_schedule: {{pillar.get('duplicity-backup', {}).get('cleanup-cron-schedule', '0 10 1 * *')}}
{% else %}
duplicity-crontab:
    file.absent:
        - name: /etc/cron.d/duplicity
{% endif %}
