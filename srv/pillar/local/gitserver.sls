gitserver:
    allowed_users:
        # copies all ssh keys from users['ssh_keys'] to the git user allowing them to authenticate
        - vagrant
    allowed_ssh_keys: {}
        # additional keys that are not associated with a user but should be allowed to authenticate as git