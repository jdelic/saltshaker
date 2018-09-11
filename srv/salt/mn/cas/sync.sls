# This is a helper state that is used to ensure that the authserver
# secretid is only created once the roleid has been created. Since
# Vault and authserver don't need to run on the same machine, this
# state is being required by the other states to ensure correct
# run order if authserver and Vault are co-located.
authserver-config-secretid-sync:
    cmd.run:
        - name: /bin/true
