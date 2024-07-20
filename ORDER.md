# State ordering

Salt allows states to be put into "tiers" which, if possible, are executed in
order, by setting the `order:` attribute on a state. The saltshaker repo
relies on a couple of state tiers what you can use so your own states are
executed in the correct order:

# Tiers ("order:" values)

Tier | Description
-----|-----------------------------------------------------
   1 | Reserved for baseline repository states
   2 | Reserved for baseline nftables states
   3 | Reserved for baseline nftables states
   4 | Reserved for baseline nftables states
   5 | Reserved for baseline nftables states
   9 | Reserved for base package install
  10 | Pull package install jobs to the front of the queue
  15 | Pull database server jobs to the front of the queue
  20 | Pull database setup jobs to the front of the queue
 100 | Used to execute jobs before other jobs without using requisites
 200 | Used to execute jobs after other jobs without using requisites
 
`order: 100` and `order:200` are used to enforce order on states that
must run after one another when they are co-located on the same server. In
that case, using a requisite directive is usually impossible since those
can't be made optional. If there is a dependency chain, values between `100`
and `199` and `200` and `299` are used respectively.

`order: 20` is used to make sure that a database exists for a subsequently
installed *unordered* state if **the database and state exist on the same 
server**. Otherwise you must make sure to install one machine after the other.

`order: 15` is used to make sure that database server setup is completed before
jobs marked with `order: 20` run. For example, cluster setup for PostgreSQL.

`order: 10` is used to pull important system packages to the front of the
queue, like salt module dependencies.
