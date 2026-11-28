include:
    - vault.sync
    - opensmtpd.sync


greylistd-frontend-vault-oidc-reader-token-policy:
    cmd.run:
        - name: >-
            echo 'path "secret/oauth2/greylistd-frontend" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write greylistd_frontend_oidc_reader -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep greylistd_frontend_oidc_reader >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


greylistd-frontend-vault-create-oidc-reader-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="greylistd-frontend-oidc-reader" \
                -policy=default -policy=greylistd_frontend_oidc_reader \
                -renewable=true \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['greylistd-frontend-oidc-reader-token']}}"
        - unless: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['greylistd-frontend-oidc-reader-token']}} | jq -r .data.ttl)" -gt 100
        - require:
            - cmd: greylistd-frontend-vault-oidc-reader-token-policy
        - require_in:
            - cmd: greylistd-frontend-sync-vault
