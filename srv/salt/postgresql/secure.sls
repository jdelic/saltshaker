
include:
    - postgresql.sync


secure-base-dir:
    file.directory:
        - name: /secure/postgres
        - user: postgres
        - group: postgres
        - mode: '0750'
        - require:
            - secure-mount


secure-tablespace-dir:
    file.directory:
        - name: /secure/postgres/main
        - user: postgres
        - group: postgres
        - mode: '0750'
        - makedirs: True
        - require:
            - file: secure-base-dir

{% if pillar.get('postgresql', {}).get('start-cluster', True) %}
secure-tablespace:
    postgres_tablespace.present:
        - name: secure
        - directory: /secure/postgres/main
        - db_user: postgres
        - user: postgres
        - require:
            - data-cluster-service
            - secure-tablespace-dir
        - require_in:
            - cmd: postgresql-sync
{% endif %}

postgresql-systemd-secure-mount-override:
    file.managed:
        - name: /etc/systemd/system/postgresql.service.d/secure-mount.conf
        - source: salt://postgresql/systemd-override.conf
        - mode: 644
        - makedirs: True
        - require:
            - file: secure-tablespace-dir
        - watch_in:
            - service: data-cluster-service
        - require_in:
            - cmd: postgresql-sync

# vim: syntax=yaml
