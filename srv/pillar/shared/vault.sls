vault:
    # Set this to 'True' to make this Salt config initialize Vault automatically
    initialize: True
    create-database: True

    # On first setup and therefor for Salt states using Vault, this Salt config will
    # also *unseal* Vault the first time Vault is initialized (at which point it should
    # be empty and therefor that's not a dangerous operation). Salt will then promptly
    # forget the unseal keys. On every subsequent run, an administrator will have to
    # unseal Vault first.
    #
    # By default, the configuration will save the keys in /root/vault_keys.txt. If
    # you set 'encrypt-with-gpg' to a known GPG public key ID in the managed keyring,
    # Vault's unseal keys will be saved in /root/vault_keys.txt.gpg instead without
    # ever being written to disk.
    #
    # PROVIDE A HEX ID! AND YOU MUST AT LEAST PROVIDE THE KEY'S LONG ID (last 16
    # characters).
    encrypt-vault-keys-with-gpg: 23FC12D75291ED448C0728C877C339AB7CDC4589
