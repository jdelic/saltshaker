# State ordering

Salt allows states to be put into "tiers" which, if possible, are executed in
order, by setting the `order:` attribute on a state. The saltshaker repo
relies on a couple of state tiers what you can use so your own states are
executed in the correct order:

# Tiers ("order:" values)

Tier | Description
-----|-----------------------------------------------------
 1   | Reserved for baseline iptables states
 2   | Reserved for baseline iptables states
 3   | Reserved for baseline iptables states
10   | Pull package install jobs to the front of the queue
15   | Pull database server jobs to the front of the queue
20   | Pull database setup jobs to the front of the queue

`order: 20` is used to make sure that a database exists for a subsequently
installed *unordered* state if **the database and state exist on the same 
server**. Otherwise you must make sure to install one machine after the other.

`order: 15` is used to make sure that database server setup is completed before
jobs marked with `order: 20` run. For example, cluster setup for PostgreSQL.

`order: 10` is used to pull important packages to the front of the queue, like
salt module dependencies.
