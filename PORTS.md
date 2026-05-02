# PORT ASSIGNMENTS

|  PORT | SMARTSTACK | ASSIGNED SERVICE                           |
|------:|:----------:|:-------------------------------------------|
|    25 |     X*     | SMTP                                       |
|   143 |            | IMAP                                       |
|   993 |            | IMAP                                       |
|  5432 |     X      | PostgreSQL                                 |
|  5433 |     X      | PostgreSQL secure (currently unused)       |
|  6379 |     X      | Redis internal network (shared)            |
|  6380 |            | Redis local cache (not shared)             |
|  7880 |            | livekit ws                                 |
|  7881 |            | livekit rtc.tcp_port                       |
|  8081 |            | livekit JWT                                |
|  8100 |     X      | aptly API                                  |
|  8200 |     X      | Vault                                      |
|  8201 |     X      | Vault Goldfish UI                          |
|  8300 |            | consul raft                                |
|  8301 |            | consul gossip                              |
|  8302 |            | consul wan                                 |
|  8448 |            | matrix synapse federation                  |
|  8500 |            | consul http                                |
|  8600 |            | consul dns                                 |
|  8990 |            | caldav                                     |
|  8999 |     X      | authserver                                 |
| 10001 |            | anytype TCP                                |
| 10002 |            | anytype TCP                                |
| 10003 |            | anytype TCP                                |
| 10004 |            | anytype TCP                                |
| 10005 |            | anytype TCP                                |
| 10006 |            | anytype TCP                                |
| 10011 |            | anytype UDP                                |
| 10012 |            | anytype UDP                                |
| 10013 |            | anytype UDP                                |
| 10014 |            | anytype UDP                                |
| 10015 |            | anytype UDP                                |
| 10016 |            | anytype UDP                                |
| 10025 |            | Amavisd -> OpenSMTPD                       |
| 10026 |            | OpenSMTPD -> Amavisd                       |
| 10035 |            | dkimsigner -> OpenSMTPD                    |
| 10036 |            | OpenSMTPD -> dkimsigner                    |
| 10037 |            | dkimsigner -> OpenSMTPD (transactional)    |
| 10038 |            | OpenSMTPD -> dkimsigner (transactional)    |
| 10045 |            | mailforwarder -> OpenSMTPD                 |
| 10046 |            | OpenSMTPD -> mailforwarder                 |
| 10047 |            | mailforwarder -> OpenSMTPD (transactional) |
| 31080 |     X      | vaultwarden API                            |
| 31300 |     X      | standardnotes API                          |
| 31301 |     X      | standardnotes web app                      |
| 32022 |     X      | SSH port forward for git miniserver        |
| 32080 |     X      | apache HTTP                                |
| 32443 |     X      | apache HTTPS                               |
| 50100 |            | livekit UDP                                |
| 50101 |            | livekit UDP                                |
| 50102 |            | livekit UDP                                |
| 50103 |            | livekit UDP                                |
| 50104 |            | livekit UDP                                |
| 50105 |            | livekit UDP                                |
| 50106 |            | livekit UDP                                |
| 50107 |            | livekit UDP                                |
| 50108 |            | livekit UDP                                |
| 50109 |            | livekit UDP                                |

`*` Only internal SMTP relays for transactional mail are routed through
SmartStack. The mail servers meant for humans (SMTP relay and SMTP
receiver) are not routed through SmartStack.
