# TODO

 * add consul service defs to sogo, apache2
 * add health checks for services monitored through consul
 * write docs for placeholders in README.md
 * all PHP should run through php-fpm behind Apache2
 * add Pillar config for a list of application apt repositories?
 * add Nagios/Icinca/xyz monitoring via consul-template
 * clean up the MySQL state folder
 * add a consul-template cmd.wait watcher state for haproxy.internal that deletes the servicerenderer
   if the command-line parameters change, because consul-template will not do it by itself


# Ponder

 * front consul through dnscache and make /etc/resolv.conf point to local dnscache? What about IPv6?

 * Docker containers should probably only expose HTTP to be reverse proxied through haproxy
     * how does consul discover docker services? -> docker registrator https://github.com/gliderlabs/registrator
     * how do php-fpm applications gain a HTTP server inside of a docker container? multi-process?

  * Fix consul to enable ACLs and then use ACL tokens to secure write access on the cluster from the agents?
    Does that make sense? Is it overkill? How can you bootstrap this from Salt?


# Whenever

 * Fix vault.mysql.database state to use salt.network.interface function to load the IP and netmask of the
   internal interface and calculate the correct network string for the MySQL GRANT command so we don't allow
   connections from just about anywhere.
