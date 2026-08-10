envoy:
    file.managed:
        - name: /usr/local/bin/envoy
        - source: {{pillar["urls"]["envoy"]}}
        - source_hash: {{pillar["hashes"]["envoy"]}}
        - mode: '0755'
        - user: root
        - group: root
        - replace: False
    group.present:
        - name: envoy
    user.present:
        - name: envoy
        - gid: envoy
        - createhome: False
        - shell: /sbin/nologin
        - home: /etc/envoy
        - require:
            - group: envoy


envoy-multi:
    systemdunit.managed:
        - name: /etc/systemd/system/envoy@.service
        - source: salt://envoy/envoy@.service
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: envoy
            - user: envoy


envoy-config-dir:
    file.directory:
        - name: /etc/envoy
        - makedirs: True
