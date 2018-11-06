
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

# vim: syntax=yaml
