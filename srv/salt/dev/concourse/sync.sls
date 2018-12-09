# A sync state for concourse being installed and ready
concourse-sync:
    cmd.run:
        - name: /bin/true concourse-sync


# for concourse and authserver being installed on the same server, this state can be a requisite
# to check for the oauth2 credentials being installed
concourse-sync-oauth2:
    cmd.run:
        - name: /bin/true concourse-sync-oauth2


# Ensure that all Vault policies and tokens have been set up
concourse-sync-vault:
    cmd.run:
        - name: /bin/true concourse-sync-vault
