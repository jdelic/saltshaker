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


email-storage-tmp:
    file.directory:
        - name: {{salt['file.join'](pillar['emailstore']['path'], 'tmp')}}
        - user: virtmail
        - group: mail
        - mode: '0770'
        - require:
            - user: virtmail
            - secure-mount


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
email-backup-prescript-folder:
    file.directory:
        - name: /etc/duplicity.d/daily/prescripts/secure-email
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


email-backup-postscript-folder:
    file.directory:
        - name: /etc/duplicity.d/daily/postscripts/secure-email
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


email-backup-prescript-script:
    file.managed:
        - name: /etc/duplicity.d/daily/prescripts/secure-email/disable_delivery.sh
        - contents: |
            #!/bin/bash
            # disable deliveries for virtmail
            chmod +t {{pillar['emailstore']['path']}}
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: email-backup-prescript-folder


email-backup-postscript-script:
    file.managed:
        - name: /etc/duplicity.d/daily/postscripts/secure-email/enable_delivery.sh
        - contents: |
            #!/bin/bash
            # enable deliveries for virtmail
            chmod -t {{pillar['emailstore']['path']}}
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: email-backup-postscript-folder


email-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/secure-email
        - target: {{pillar['emailstore']['path']}}
        - require:
            - file: email-storage
{% endif %}
