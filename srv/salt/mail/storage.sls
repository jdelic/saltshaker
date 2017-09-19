mail:
    group.present


virtmail:
    user.present:
        - gid: mail
        - createhome: False
        - home: {{pillar['emailstore']['path']}}
        - shell: /bin/false
        - require:
            - group: mail


email-storage:
    file.directory:
        - name: {{pillar['emailstore']['path']}}
        - user: virtmail
        - group: mail
        - mode: '0750'
        - require:
            - user: virtmail
            - secure-mount


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
email-backup:
    file.accumulated:
        - name: duplicity-cron-folders
        - filename: {{pillar['duplicity-backup']['filename']}}
        - text: {{pillar['emailstore']['path']}}
        - require_in:
            - file: duplicity-cron
        - require:
            - file: email-storage
{% endif %}
