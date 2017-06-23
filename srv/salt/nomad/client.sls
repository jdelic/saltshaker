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
            - user: nomad
            - group: nomad


nomad-pidfile-dir:
    file.directory:
        - name: /run/nomad
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad
            - group: nomad


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
            - user: nomad  # the user is required in the .conf file
            - group: nomad


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
            - user: nomad
            - group: nomad
            - file: nomad-basedir


nomad:
    group.present:
        - name: {{nomad_group}}
    user.present:
        - name: {{nomad_user}}
        - gid: {{nomad_group}}
        - groups:
            - docker
        - createhome: False
        - home: /var/lib/nomad
        - shell: /bin/sh
        - require:
             - group: nomad
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["nomad"]}}
        - source_hash: {{pillar["hashes"]["nomad"]}}
        - archive_format: zip
        - if_missing: /usr/local/bin/nomad
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/nomad
        - mode: '0755'
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - replace: False
        - require:
            - user: nomad
            - file: nomad-pidfile-dir
            - file: nomad-data-dir
            - archive: nomad
