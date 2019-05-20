# require this state to ensure that PostgreSQL is properly set up if the requiring
# state is run on the same server
postgresql-sync:
    cmd.run:
        - name: /bin/true postgresql-sync
