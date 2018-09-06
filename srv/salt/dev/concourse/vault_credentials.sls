# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if concourse
# is not configured to use Vault.

include:
    - vault.sync


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


concourse-vault-approle-role-id:
    cmd.run:
        - name: >-
            vault write auth/approle/role/concourse/role-id \
                role_id="{{pillar['dynamicsecrets']['concourse-role-id']}}"
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - onchanges:
            - cmd: concourse-vault-approle


concourse-vault-secrets-policy:
    cmd.run:
        - name: >-
            echo 'path "concourse/*" {
                capabilities=["read", "list"]
            }' | /usr/local/bin/vault policy write concourse_secrets -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep concourse_secrets >/dev/null
        - onlyif: /usr/local/bin/vault operator init -status >/dev/null
        - require:
            - cmd: vault-sync
{% endif %}
