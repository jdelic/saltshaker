
include:
    - redis.install


redis-config:
    file.managed:
        - name: /etc/redis/redis.conf
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
        - in-interface: {{pillar['ifassign']['internal']}}
        - destination: {{pillar.get('redis-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
        - dport: {{pillar.get('redis-server', {}).get('bind-port', 6379)}}
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables
            - pkg: redis


redis-servicdef:
    file.managed:
        - name: /etc/consul/services.d/redis-cache.json
        - source: salt://redis/consul/redis.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{pillar.get('redis-server', {}).get('bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int()])}}
            port: {{pillar.get('redis-server', {}).get('bind-port', 6379)}}
        - require:
            - service: redis
            - file: consul-service-dir
