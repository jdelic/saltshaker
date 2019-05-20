# install haproxy

haproxy-repo:
    pkgrepo.managed:
        - name: {{pillar['repos']['haproxy']}}
        - file: /etc/apt/sources.list.d/haproxy.list
        - key_url: salt://haproxy/bernat.debian.org.pgp.key


haproxy:
    pkg.installed:
        - install_recommends: False
        - fromrepo: stretch-backports-1.8
        - require:
            - pkgrepo: haproxy-repo
    service.dead:
        - name: haproxy
        - enable: False
        - prereq:
            - systemdunit: haproxy-multi
    file.absent:
        - name: /etc/init.d/haproxy
        - require:
            - service: haproxy


# set up a systemd config that supports multiple haproxy instances on one machine
haproxy-multi:
    systemdunit.managed:
        - name: /etc/systemd/system/haproxy@.service
        - source: salt://haproxy/haproxy@.service
        - user: root
        - group: root
        - mode: '0644'
        # note that there is NO dependency to pkg: haproxy here! This is because we declare haproxy to be
        # a prereq of service:haproxy-multi
{% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) %}
        - require:
            - cmd: haproxy-dhparams
{% endif %}

haproxy-remove-packaged-config:
    file.absent:
        - name: /etc/haproxy/haproxy.cfg


{% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) %}
# create our own dhparams for more SSL security
haproxy-dhparams:
    file.directory:
        - name: /etc/haproxy
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
    cmd.run:
        - name: openssl dhparam -out /etc/haproxy/dhparams.pem 2048
        - creates: /etc/haproxy/dhparams.pem
        - require:
            - file: haproxy-dhparams
{% endif %}


haproxy-data-dir:
    file.directory:
        - name: /run/haproxy
        - makedirs: True
        - user: haproxy
        - group: haproxy
        - mode: '2755'
        - require:
            - pkg: haproxy


haproxy-data-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/haproxy.conf
        - source: salt://haproxy/haproxy.tmpfiles.conf
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: haproxy


# vim: syntax=yaml
