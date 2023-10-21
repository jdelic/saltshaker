#
# installs a helper script that unlocks Vault on development machines
#

{% if not pillar['vault'].get('encrypt-vault-keys-with-gpg', False) %}

vault-autounlock-script:
    file.managed:
        - name: /root/vault_unlock.sh
        - source: salt://vault/vault_unlock.sh
        - mode: '0700'
        - user: root
        - group: root

{% endif %}
