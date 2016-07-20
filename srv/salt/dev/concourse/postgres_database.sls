
# this state should be run on a server role with postgressql.fast

concourse-db-role:
    postgres_user.present:
        - name: concourse
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - password: {{piller['dynamicpasswords']['concourse-db']}}
        - user: postgres


concourse-db:
    postgres_database.present:
        - name: concourse
        - encoding: utf-8
        - owner: concourse
        - user: postgres
        - require:
            - postgres_user: concourse-db-role
            - data-cluster
