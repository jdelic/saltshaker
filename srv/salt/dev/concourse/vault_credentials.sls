# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if concourse
# is not configured to use Vault.
{% if pillar.get('concourse', {}).get('use-vault', False) %}
concourse-vault-approle:
    cmd.run:
        - name: >-
            vault write auth/approle/role/concourse \
                bind_secret_id=true \
                token_num_uses=0 \
                secret_id_num_uses = 0 \
                period=45m \
                token_ttl=45m \
                token_max_ttl=60m \
                secret_id_ttl=30m \
                policies=["concourse_secrets"]
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault list auth/approle/rol | grep concourse_secrets >/dev/null
        - onlyif: /usr/local/bin/vault init -check >/dev/null


concourse-vault-secrets-policy:
    cmd.run:
        - name: >-
            echo 'path "concourse/*" {
                capabilities=["read", "list"]
            }' | /usr/local/bin/vault policy-write concourse_secrets -
        - env:
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - unless: /usr/local/bin/vault policies | grep concourse_secrets >/dev/null
        - onlyif: /usr/local/bin/vault init -check >/dev/null
{% endif %}
