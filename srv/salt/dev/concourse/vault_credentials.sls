# This state must be assigned to whatever node runs Hashicorp Vault and will be empty if AuthServer
# is not configured to use Vault.
{% if pillar.get('concourse', {}).get('use-vault', False) %}



{% endif %}
