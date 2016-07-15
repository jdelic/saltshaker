
secure-base-dir:
    file.directory:
        - name: /secure/postgres
        - user: postgres
        - group: postgres
        - mode: '0750'
        - require:
            - secure-mount

secure-tablespace:
    postgres_tablespace.present:
        - name: secure
        - directory: /secure/postgres/9.4/main
        - db_user: postgres
        - user: postgres
        - require:
            - data-cluster
            - secure-base-dir


# vim: syntax=yaml
