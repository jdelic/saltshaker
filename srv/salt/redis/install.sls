redis-install:
    pkg.installed:
        - pkgs:
            - redis-server
            - redis-tools


debian-redis-remove:
    service.dead:
        - name: redis-server
        - enable: False
        - prereq:
            - systemdunit: redis-multi
        - require:
            - pkg: redis-install
    file.absent:
        - name: /lib/systemd/system/redis-server.service
        - require:
            - service: debian-redis-remove


debian-redis-config-remove:
    file.absent:
        - name: /etc/redis/redis.conf
        - require:
            - service: debian-redis-remove


# set up a systemd config that supports multiple redis instances on one machine
redis-multi:
    systemdunit.managed:
        - name: /etc/systemd/system/redis@.service
        - source: salt://redis/redis@.service
        - user: root
        - group: root
        - mode: '0644'


remove-stale-redis-log-file:
    file.absent:
        - name: /var/log/redis/redis-server.log


redis-data-dir:
    file.directory:
        - name: /run/redis
        - makedirs: True
        - user: redis
        - group: redis
        - mode: '2755'
        - require:
            - pkg: redis-install


# this is now provided by the package
#redis-data-dir-systemd:
#    file.managed:
#        - name: /usr/lib/tmpfiles.d/redis-server.conf
#        - source: salt://redis/redis.tmpfiles.conf
#        - user: root
#        - group: root
#        - mode: '0644'
#        - require:
#            - pkg: redis

# vim: syntax=yaml
