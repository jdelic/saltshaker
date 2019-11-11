#!/usr/bin/env bash

cat /root/vault_keys.txt | grep "Unseal Key:" | cut -d' ' -f4 | head -3 | xargs -n 1 vault operator unseal
