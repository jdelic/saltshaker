# State ordering

Salt allows states to be put into "tiers" which, if possible, are executed in
order, by setting the `order:` attribute on a state. The saltshaker repo 
relies on a couple of state tiers what you can use so your own states are 
executed in the correct order:

# Tiers ("order:" values)

Tier | Description
-----|---------------------------------------------------
 1   | Reserved for baseline iptables states
 2   | Reserved for baseline iptables states
 3   | Reserved for baseline iptables states
10   | Pull database setup jobs to the front of the queue

`order: 10` allows you to make sure that a database exists for a subsequently
installed state if **the database and state exist on the same server**. 
Otherwise you must make sure to install one after the other.
