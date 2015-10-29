
include:
    - redis.install


redis-config:
    file.managed:
        - name: /etc/redis/redis.conf
        - source: salt://redis/redis.jinja.conf
        - template: jinja
        - context:
            ip: {{pillar.get('redis-local', {}).get('bind-ip', '127.0.0.1')}}
            port: {{pillar.get('redis-local', {}).get('bind-port', 6380)}}
            instance: local
        - require:
            - pkg: redis
        - unless:
            - sls: redis.cache
