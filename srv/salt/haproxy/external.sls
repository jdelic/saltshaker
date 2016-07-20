# TODO:
# This state is supposed to setup consul-template so that it renders a haproxy
# configuration that queries all services tagged as external in the local network
# and then creates a loadbalancer across all of them.

# Ideally it uses some form of consul tag to automatically match the HTTP Host
# header, too. What remains then is the question of SNI and SSL certificates,
# i.e. SSL termination.

# Also unsolved: Port autodiscovery for internal routing. A consul servicedef
# should probably tag a service with its SmartStack default port.

# Finally the resulting haproxy instance would run on ports 80 and 443.

include:
    - haproxy.install


haproxy-config-template-external:
    file.managed:
        - name: /etc/haproxy/haproxy-external.jinja.cfg
        - source: salt://haproxy/haproxy-external.jinja.cfg
        - require:
            - pkg: haproxy


smartstack-external:
    file.managed:
        - name: /etc/consul/template.d/smartstack-external.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-external.py
            target: /etc/haproxy/haproxy-external.cfg
            # this (yaml folded) command-line will reload haproxy if it is running and restart it otherwise
            command: >
                ps awwfux | grep -v grep | grep -q 'haproxy -f /etc/haproxy/haproxy-external.cfg' &&
                systemctl reload haproxy@external ||
                systemctl restart haproxy@external
            parameters: --has smartstack:external --localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
            template: /etc/haproxy/haproxy-external.jinja.cfg
        - require:
            - file: haproxy-config-template-external
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@external
        - require:
            - file: haproxy-multi
            - file: smartstack-external

# vim: syntax=yaml
