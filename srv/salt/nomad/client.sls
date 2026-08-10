#
# Install Hashicorp's nomad Docker-based cluster manager from a .zip file and join it to the
# system-wide consul network.
#


{% set nomad_user = "nomad" %}
{% set nomad_group = "nomad" %}


nomad-data-dir:
    file.directory:
        - name: /var/lib/nomad
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad-user
            - group: nomad-user


nomad-pidfile-dir:
    file.directory:
        - name: /run/nomad
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad-user
            - group: nomad-user


nomad-pidfile-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/nomad.conf
        - source: salt://nomad/nomad.tmpfiles.conf
        - template: jinja
        - context:
            user: {{nomad_user}}
            group: {{nomad_group}}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - user: nomad-user  # the user is required in the .conf file
            - group: nomad-user


nomad-basedir:
    file.directory:
        - name: /etc/nomad
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


nomad-service-dir:
    file.directory:
        - name: /etc/nomad/services.d
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad-user
            - group: nomad-user
            - file: nomad-basedir


nomad-user:
    group.present:
        - name: {{nomad_group}}
    user.present:
        - name: {{nomad_user}}
        - gid: {{nomad_group}}
        - createhome: False
        - home: /var/lib/nomad
        - shell: /bin/sh
        - require:
             - group: nomad-user


nomad:
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["nomad"]}}
        - source_hash: {{pillar["hashes"]["nomad"]}}
        - archive_format: zip
        - unless: test -f /usr/local/bin/nomad  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/bin/nomad
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/nomad
        - mode: '0755'
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - replace: False
        - require:
            - user: nomad-user
            - file: nomad-pidfile-dir
            - file: nomad-data-dir
            - archive: nomad


nomad-cni-configdir:
    file.directory:
        - name: /etc/nomad/cni
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


nomad-cni-installdir:
    file.directory:
        - name: /usr/local/lib/nomad
        - makedirs: True
        - mode: '0755'


nomad-cni:
    archive.extracted:
        - name: /usr/local/lib/nomad
        - source: {{pillar["urls"]["nomad-cni"]}}
        - source_hash: {{pillar["hashes"]["nomad-cni"]}}
        - archive_format: tar
        - unless: test -f /usr/local/lib/nomad/bridge  # workaround for https://github.com/saltstack/salt/issues/42681
        - enforce_toplevel: False
        - require:
            - file: nomad-cni-installdir
            - file: nomad-cni-configdir
        - require_in:
            - file: nomad
