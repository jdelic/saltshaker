# PORT ASSIGNMENTS

PORT     | SMARTSTACK | ASSIGNED SERVICE
--------:|:----------:|:-----------------------------------------
    25   |      X*    | SMTP
   143   |            | IMAP
   993   |            | IMAP
  5432   |      X     | PostgreSQL
  5433   |      X     | PostgreSQL secure (currently unused)
  6379   |      X     | Redis internal network (shared)
  6380   |            | Redis local cache (not shared)
  8100   |      X     | aptly API
  8200   |      X     | Vault
  8201   |      X     | Vault Goldfish UI
  8300   |            | consul raft
  8301   |            | consul gossip
  8302   |            | consul wan
  8500   |            | consul http
  8600   |            | consul dns
  8990   |            | caldav
  8999   |      X     | authserver
 32080   |      X     | apache HTTP
 32443   |      X     | apache HTTPS



`*` Only internal SMTP relays for transactional mail are routed through
SmartStack. The mail servers meant for humans (SMTP relay and SMTP
receiver) are not routed through SmartStack.
