# Common gpg config for a shared keyring managed by Salt
#
# This allows the distribution of public and private keys into a keyring
# that only system users who are members of the group "gpg-access" can
# read.

gpg:
    shared-keyring-location: /etc/gpg-managed-keyring
