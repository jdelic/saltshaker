# This state ensures that authserver is up and running
authserver-sync:
    cmd.run:
        - name: /bin/true authserver-sync


# This is a helper state that is used to ensure that the authserver
# secretid is only created once the roleid has been created. Since
# Vault and authserver don't need to run on the same machine, this
# state is being required by the other states to ensure correct
# run order if authserver and Vault are co-located. This also syncs
# all Vault policies.
authserver-sync-vault:
    cmd.run:
        - name: /bin/true authserver-sync-vault


dkimsigner-sync-vault:
    cmd.run:
        - name: /bin/true dkimsigner-sync-vault


mailforwarder-sync-vault:
    cmd.run:
        - name: /bin/true mailforwarder-sync-vault
