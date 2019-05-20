# require this state to ensure that Vault is properly set up if the requiring
# state is run on the same server
vault-sync:
    cmd.run:
        - name: /bin/true vault-sync
        - require:
            - cmd: vault-sync-database


vault-sync-database:
    cmd.run:
        - name: /bin/true vault-sync-database
