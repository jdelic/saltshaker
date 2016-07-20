
# both states below are empty if the backend hasn't been selected in the shared.vault pillar
include:
    - vault.mysql_database
    - vault.postgres_database
