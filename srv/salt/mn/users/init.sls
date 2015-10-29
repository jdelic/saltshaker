
sudo:
    pkg.installed

root:
    user.present:
        - uid: 0
        - gid: 0
        - home: /root
        - password:

root-bashrc:
    file.managed:
        - name: /root/.bashrc
        - source: salt://mn/users/bashrc.root
        - user: root
        - group: root
        - mode: 640

# vim: syntax=yaml

