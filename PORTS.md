# PORT ASSIGNMENTS

PORT   | SMARTSTACK | ASSIGNED SERVICE
------:|:----------:|:----------------
  25   |      X*    | SMTP
 143   |            | IMAP
 993   |            | IMAP
3306   |      X     | MySQL "fast" (not encrypted)
3307   |      X     | MySQL "secure" (encrypted)
6379   |      X     | Redis internal network (shared)
6380   |            | Redis local cache (not shared)
8200   |      X     | Vault
8999   |      X     | authserver

`*` Only internal SMTP relays for transactional mail are routed through
SmartStack. The mail servers meant for humans (SMTP relay and SMTP
receiver) are not routed through SmartStack.

