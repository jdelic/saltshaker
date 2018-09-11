
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
        - name: /secure/postgres/10/main
        - user: postgres
        - group: postgres
        - mode: '0750'
        - makedirs: True
        - require:
            - file: secure-base-dir


secure-tablespace:
    postgres_tablespace.present:
        - name: secure
        - directory: /secure/postgres/10/main
        - db_user: postgres
        - user: postgres
        - require:
            - data-cluster-service
            - secure-tablespace-dir
        - require_in:
            - cmd: postgresql-sync

# vim: syntax=yaml
