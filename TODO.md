# TODO

 * add consul service defs to apache2
 * add health checks for services monitored through consul
 * write docs for placeholders in README.md
 * add Nagios/Icinca/xyz monitoring via consul-template
 * add a consul-template cmd.wait watcher state for haproxy.internal that
   deletes the servicerenderer if the command-line parameters change, because
   consul-template will not do it by itself (has this been fixed upstream?)
 * add a logging server role
 * write docs for duplicity config folder structure
 * add prescripts for email storage backup that disable opensmtpd delivery
   by setting +t on the Maildirs
 
# Ponder

 * how do php-fpm applications gain a HTTP server inside of a docker
   container? multi-process?

 * should `postgresql.secure` be its own cluster on port 5433?

 * add PowerDNS states to implement a fully owned DNSSEC zone (i.e. no trust
   delegation to third parties)

 * switch Dovecot from maildir to sdbox
