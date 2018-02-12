# this state installs a chrooted sftp server for Photosync (iOS app)


photosync-secure-storage:
    file.directory:
        - name: /secure/photosync
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - secure-mount


photosync-sftp-config-enable-sftp:
    file.managed:
        - name: /etc/ssh/sshd_config.d/01-enable-sftp
        - contents: |
            Subsystem       sftp    internal-sftp
        - require:
            - file: openssh-config-folder


{% for photosync_svc in pillar['photosync'] %}
photosync-group-{{photosync_svc}}:
    group.present:
        - name: ps-{{photosync_svc}}


photosync-folder-{{photosync_svc}}:
    file.directory:
        - name: /secure/photosync/{{photosync_svc}}
        - user: root
        - group: ps-{{photosync_svc}}
        - mode: '0770'
        - require:
            - file: photosync-secure-storage
            - group: photosync-group-{{photosync_svc}}


    {% for photosync_user in pillar['photosync'][photosync_svc] %}
photosync-{{photosync_svc}}-user-{{photosync_user}}:
    user.present:
        - name: {{photosync_user}}
        - gid: ps-{{photosync_user}}
        - password: {{pillar['photosync'][photosync_svc][photosync_user]}}
        - home: /secure/photosync/{{photosync_svc}}
        - require:
            - group: photosync-group-{{photosync_svc}}
            - file: photosync-folder-{{photosync_svc}}
    {% endfor %}


photosync-sftp-config-{{photosync_svc}}:
    file.managed:
        - name: /etc/ssh/sshd_config.d/10-photosync-sftp-{{loop.index}}
        - contents: |
            Match Group ps-{{photosync_svc}}
                ForceCommand internal-sftp
                ChrootDirectory /secure/photosync/{{photosync_svc}}
                X11Forwarding no
                AllowTcpForwarding no
        - require:
            - file: photosync-folder-{{photosync_svc}}
            - group: photosync-group-{{photosync_svc}}
        - watch_in:
            - cmd: openssh-config-builder
{% endfor %}
