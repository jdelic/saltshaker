# configuration values that should be accessible to all nodes in the local environment
# This should include configuration values that have no security impact and are widely required to run multiple
# services and can be reasonably expected to remain constant across an environment.

{% set external_tld = "maurus.net" %}

sudoers_allow_nopasswd: False
tld: {{external_tld}}
