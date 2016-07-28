
# this state should be run on a server role with postgressql.fast

concourse-db-role:
    postgres_user.present:
        - name: concourse
        - password: {{pillar['dynamicpasswords']['concourse-db']}}
        - createdb: False
        - createroles: False
        - createuser: False
        - encrypted: True
        - login: True
        - inherit: False
        - superuser: False
        - replication: False
        - user: postgres
        - require:
            - data-cluster-service


concourse-db:
    postgres_database.present:
        - name: concourse
        - encoding: utf8  # postgresql spelling
        - owner: concourse
        - user: postgres
        - order: 20  # see ORDER.md
        - require:
            - postgres_user: concourse-db-role
            - data-cluster-service
