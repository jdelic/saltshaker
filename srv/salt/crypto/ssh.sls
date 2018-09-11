openssh:
    pkg.installed:
        - pkgs:
            - ssh
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


openssh-config-folder:
    file.directory:
        - name: /etc/ssh/sshd_config.d
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - pkg: openssh


openssh-config:
    file.managed:
        - name: /etc/ssh/sshd_config.d/00-sshd_config
        - source: salt://crypto/sshd_config.jinja
        - template: jinja
        - require:
            - file: openssh-config-folder
        - watch_in:
            - cmd: openssh-config-builder


openssh-config-builder:
    file.managed:
        - name: /etc/ssh/assemble-ssh-config.sh
        - source: salt://crypto/assemble-sshd-config.sh
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: openssh-config-folder
    cmd.run:
        - name: /etc/ssh/assemble-ssh-config.sh
        - watch:
            - file: /etc/ssh/sshd_config.d*


{% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) %}
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
        - watch_in:
            - service: openssh-reload
{% endif %}


# IPTABLES setup is performed with other core services in basics
