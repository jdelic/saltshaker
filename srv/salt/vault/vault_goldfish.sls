goldfish-vault-approle:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/goldfish \
                role_name=goldfish \
                policies=default,goldfish \
                secret_id_num_uses=0 \
                secret_id_ttl=15m \
                period=24h \
                token_ttl=0 \
                token_max_ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: vault-approle-auth-enabled


goldfish-vault-approle-roleid:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write auth/approle/role/goldfish/role-id \
                role_id={{pillar['dynamicsecrets']['goldfish-role-id']}}
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: goldfish-vault-approle


goldfish-vault-policy:
    cmd.run:
        - name: >-
            echo '# [mandatory]
                  # store goldfish run-time settings here
                  # goldfish hot-reloads from this endpoint every minute
                  path "secret/goldfish" {
                      capabilities = ["read", "update"]
                  }


                  # [optional]
                  # to enable transit encryption, see wiki for details
                  path "transit/encrypt/goldfish" {
                      capabilities = ["read", "update"]
                  }
                  path "transit/decrypt/goldfish" {
                      capabilities = ["read", "update"]
                  }


                  # [optional]
                  # for goldfish to fetch certificates from PKI backend
                  #path "pki/issue/goldfish" {
                  #    capabilities = ["update"]
                  #}' | /usr/local/bin/vault policy-write goldfish -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep goldfish >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null


goldfish-vault-config:
    cmd.run:
        - name: >-
            /usr/local/bin/vault write secret/goldfish \
                DefaultSecretPath="secret/" \
                UserTransitKey="usertransit" \
                BulletinPath="secret/bulletins/"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: goldfish-vault-approle
