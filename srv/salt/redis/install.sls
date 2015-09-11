redis:
    pkg.installed:
        - pkgs:
            - redis-server
            - redis-tools
    service.running:
        - name: redis-server
        - enable: True
        - require:
            - pkg: redis
        - watch:
            - file: /etc/redis/redis.conf


remove-stale-redis-log-file:
    file.absent:
        - name: /var/log/redis/redis-server.log


redis-data-dir:
    file.directory:
        - name: /run/redis
        - makedirs: True
        - user: redis
        - group: redis
        - mode: '0755'
        - require:
            - pkg: redis


redis-data-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/redis.conf
        - source: salt://redis/redis.tmpfiles.conf
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: redis

# vim: syntax=yaml
