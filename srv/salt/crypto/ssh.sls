openssh:
    pkg.installed:
        - pkgs:
            - ssh
            - openssh-blacklist
            - openssh-blacklist-extra
            - openssh-server
            - openssh-client
            - libssh2-1
        - install_recommends: False
    service.running:
        - name: sshd
        - sig: sshd
        - enable: True


openssh-reload:
    service.running:
        - name: sshd
        - sig: sshd
        - enable: True
        - reload: True
        - watch:
            - file: openssh-config
            - file: openssh-replace-moduli


openssh-config:
    file.managed:
        - name: /etc/ssh/sshd_config
        - source: salt://crypto/sshd_config.jinja
        - template: jinja
        - require:
            - pkg: openssh


openssh-generate-moduli:
    cmd.run:
        - name: ssh-keygen -G /etc/ssh/moduli.tmp -b 2048
        - onlyif: grep -q " 1023 " /etc/ssh/moduli
        - unless: test -e /etc/ssh/moduli.tmp || test -e /etc/ssh/moduli.safe


openssh-filter-moduli:
    cmd.run:
        - name: ssh-keygen -T /etc/ssh/moduli.safe -f /etc/ssh/moduli.tmp && rm /etc/ssh/moduli.tmp
        - onlyif: test -e /etc/ssh/moduli.tmp
        - require:
            - cmd: openssh-generate-moduli


openssh-replace-moduli:
    file.rename:
        - name: /etc/ssh/moduli
        - source: /etc/ssh/moduli.safe
        - force: True
        - watch:
            - cmd: openssh-filter-moduli


# IPTABLES setup is performed with other core services in basics
