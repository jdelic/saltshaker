include:
    - vault.sync
    - vaultwarden.sync

{% if pillar['vaultwarden'].get('enabled', False) %}

vaultwarden-vault-oidc-reader-token-policy:
    cmd.run:
        - name: >-
            echo 'path "secret/oauth2/vaultwarden" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write vaultwarden_oidc_reader -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep vaultwarden_oidc_reader >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync


vaultwarden-vault-create-oidc-reader-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="vaultwarden-oidc-reader" \
                -policy=default -policy=vaultwarden_oidc_reader \
                -renewable=true \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['vaultwarden-oidc-reader-token']}}"
        - unless: >-
            test "$(/usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['vaultwarden-oidc-reader-token']}} | jq -r .data.ttl)" -gt 100
        - require:
            - cmd: vaultwarden-vault-oidc-reader-token-policy
        - require_in:
            - cmd: vaultwarden-sync-vault

{% endif %}