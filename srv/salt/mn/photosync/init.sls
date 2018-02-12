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
        - onchanges_in:
            - cmd: openssh-config-builder
        - require:
            - file: openssh-config-folder


{% for photosync_svc in pillar['photosync'] %}
photosync-group-{{photosync_svc}}:
    group.present:
        - name: ps-{{photosync_svc}}


# the following two states are necessary because sftp chroots MUST be
# chown root:root with mode 0755. Since we don't want other photosync users
# to be able to see the other roots, we have to nest the homedir twice.
photosync-folder-{{photosync_svc}}-root:
    file.directory:
        - name: /secure/photosync/{{photosync_svc}}
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
        - require:
            - file: photosync-secure-storage


photosync-folder-{{photosync_svc}}:
    file.directory:
        - name: /secure/photosync/{{photosync_svc}}/photos
        - user: root
        - group: ps-{{photosync_svc}}
        - mode: '0770'
        - makedirs: True
        - require:
            - group: photosync-group-{{photosync_svc}}
            - file: photosync-folder-{{photosync_svc}}-root


    {% for photosync_user in pillar['photosync'][photosync_svc] %}
photosync-{{photosync_svc}}-user-{{photosync_user}}:
    user.present:
        - name: {{photosync_user}}
        - gid: ps-{{photosync_svc}}
        - password: {{pillar['photosync'][photosync_svc][photosync_user]}}
        - home: /photos
        - createhome: False
        - shell: /bin/false
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
        - onchanges_in:
            - cmd: openssh-config-builder
{% endfor %}
