
include:
    - redis.install


/etc/redis/redis.conf:
    file.managed:
        - source: salt://redis/redis.jinja.conf
        - template: jinja
        - context:
            ip: {{pillar.get('redis-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('redis-server', {}).get('bind-port', 6379)}}
            instance: cache
        - require:
            - pkg: redis
        - unless:
            - sls: redis.local


# allow locals to contact us on port 6379
redis-in{{pillar.get('redis-server', {}).get('bind-port', 6379)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: tcp
        - source: '0/0'
        - destination: {{pillar.get('redis-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('redis-server', {}).get('bind-port', 6379)}}
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables
            - pkg: redis


/etc/consul/services.d/redis-cache.json:
    file.managed:
        - source: salt://redis/consul/redis.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('redis-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('redis-server', {}).get('bind-port', 6379)}}
        - require:
            - service: redis
