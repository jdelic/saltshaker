
sudo:
    pkg.installed

include:
    - mn.users.manage

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


root-dotssh:
    file.directory:
        - name: /root/.ssh
        - user: root
        - group: root
        - mode: 700
        - require:
            - user: root


root-dotssh-known-hosts:
    file.managed:
        - name: /root/.ssh/known_hosts
        - user: root
        - group: root
        - mode: 640
        - require:
            - file: root-dotssh


# vim: syntax=yaml
