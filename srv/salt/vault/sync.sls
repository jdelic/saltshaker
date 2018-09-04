# require this state to ensure that Vault is properly set up if the requiring
# state is run on the same server
vault-init-sync:
    cmd.run:
        - name: /bin/true
