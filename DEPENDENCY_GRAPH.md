Dependency Reference
====================

This is how machines can be brought up in sequence:

  1. Xen Dom0 (Saltmaster + Vault + Consul server(1/3))

  2. DB DomU (PostgreSQL + Consul server (2/3))

  3. CIC DomU (Mail + PIM + AuthServer + Consul server(3/3))

  4. Dev DomU (Concourse + Compilers)

  5. Apps DomU (Loadbalancer and Docker)


