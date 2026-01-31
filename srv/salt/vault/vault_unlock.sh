#!/usr/bin/env bash

grep "^Unseal Key" /root/vault_keys.txt | cut -d' ' -f4 | head -3 | xargs -n 1 vault operator unseal
