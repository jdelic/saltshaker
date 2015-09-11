
# TODO: add php-fpm

php5-cgi:
    pkg.installed


php5-common:
    pkg.installed


php5-curl:
    pkg.installed


php5-gd:
    pkg.installed:
        - pkgs:
            - php5-gd
            - libgd3


php5-geoip:
    pkg.installed


php5-imap:
    pkg.installed


php5-mysql:
    pkg.installed


# vim: syntax=yaml

