# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if concourse
# is not configured to use Vault.

include:
    - vault.sync
    - dev.concourse.sync


{% if pillar.get('ci', {}).get('use-vault', False) %}
concourse-vault-approle:
    cmd.run:
        - name: >-
            vault write auth/approle/role/concourse \
                bind_secret_id=true \
                token_num_uses=0 \
                secret_id_num_uses=0 \
                period=60m \
                token_ttl=60m \
                token_max_ttl=0 \
                secret_id_ttl=0 \
                policies=default,concourse_secrets
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/approle/role | grep concourse >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: concourse-sync-vault


concourse-vault-approle-role-id:
    cmd.run:
        - name: >-
            vault write auth/approle/role/concourse/role-id \
                role_id="{{pillar['dynamicsecrets']['concourse-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: concourse-vault-approle
        - require_in:
            - cmd: concourse-sync-vault


concourse-vault-secrets-policy:
    cmd.run:
        - name: >-
            echo 'path "concourse/*" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write concourse_secrets -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep concourse_secrets >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: concourse-sync-vault


concourse-secret-mount:
    cmd.run:
        - name: >-
              vault secrets enable -path=concourse kv
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault secrets list | grep concourse/ >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: concourse-sync-vault


vault-concourse-oauth2-read-policy:
    cmd.run:
        - name: >-
            echo 'path "secret/oauth2/concourse" {
                capabilities = ["read", "list"]
            }' | /usr/local/bin/vault policy write oauth2_concourse_read_access -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policy list | grep oauth2_concourse_read_access >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
        - require_in:
            - cmd: concourse-sync-vault


vault-concourse-oauth2-read-token:
    cmd.run:
        - name: >-
            /usr/local/bin/vault token revoke $TOKENID;
            /usr/local/bin/vault token create \
                -id=$TOKENID \
                -display-name="oauth2-read-concourse" \
                -policy=default -policy=oauth2_concourse_read_access \
                -explicit-max-ttl=0
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
            - TOKENID: "{{pillar['dynamicsecrets']['concourse-oauth2-read']}}"
        - unless: >-
            /usr/local/bin/vault token lookup -format=json {{pillar['dynamicsecrets']['concourse-oauth2-read']}}
        - require:
            - cmd: vault-concourse-oauth2-read-policy
        - require_in:
            - cmd: concourse-sync-vault
{% endif %}
