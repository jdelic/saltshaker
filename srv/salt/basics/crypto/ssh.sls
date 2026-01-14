openssh:
    pkg.installed:
        - pkgs:
            - ssh
            - openssh-server
            - openssh-client
            - libssh2-1t64
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
        - name: /etc/ssh/sshd_config.d/00-sshd_config.conf
        - source: salt://basics/crypto/sshd_config.jinja.conf
        - template: jinja
        - require:
            - file: openssh-config-folder


openssh-client-config:
    file.managed:
        - name: /etc/ssh/ssh_config.d/mn_tmux.conf
        - source: salt://basics/crypto/ssh_config.jinja.conf
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: openssh


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
