# require this state to ensure that Vault is properly set up if the requiring
# state is run on the same server
include:
    - powerdns.sync


vault-sync:
    cmd.run:
        - name: /bin/true
        - require:
            - cmd: vault-sync-database


vault-sync-database:
    cmd.run:
        - name: /bin/true
