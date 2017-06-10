Dependency Reference
====================

This is how machines can be brought up in sequence:

  1. Xen Dom0 (Saltmaster + Consul server(1/3))

  2. DB DomU (PostgreSQL + AuthServer + Vault + Consul server (2/3))

  3. Mail DomU (Mail + PIM)

  4. Dev DomU (Concourse + Compilers + Consul server(3/3))

  5. Apps DomU (Loadbalancer, Docker, Nomad)


