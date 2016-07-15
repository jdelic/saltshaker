
concourse:
    group.present:
        - name: concourse
    user.present:
        - name: concourse
        - home: /srv/concourse
        - shell: /bin/false
        - createhome: True
        - require:
            - user: concourse


/usr/local/bin/concourse_linux_amd64:
    file.managed:
        - source: {{pillar["urls"]["concourse"]}}
        - source_hash: {{pillar["hashes"]["concourse"]}}
        - mode: '0755'
        - user: concourse
        - group: concourse
        - require:
            - user: concourse


# TODO: install systemd service def and call service.running on it
