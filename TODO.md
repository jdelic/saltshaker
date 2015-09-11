# TODO

 * add consul service defs to sogo, apache2
 * add health checks for services monitored through consul
 * write docs for placeholders in README.md
 * all PHP should run through php-fpm behind Apache2
 * add Pillar config for a list of application apt repositories?
 * add Nagios/Icinca/xyz monitoring via consul-template

# Ponder
 * front consul through dnscache and make /etc/resolv.conf point to local dnscache? What about IPv6?
 * Docker containers should probably only expose HTTP to be reverse proxied through haproxy
     * how does consul discover docker services? -> docker registrator https://github.com/gliderlabs/registrator
     * how do php-fpm applications gain a HTTP server inside of a docker container? multi-process?
