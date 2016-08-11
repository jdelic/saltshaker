
include:
    - haproxy.install


haproxy-config-template-external:
    file.managed:
        - name: /etc/haproxy/haproxy-external.jinja.cfg
        - source: salt://haproxy/haproxy-external.jinja.cfg
        - require:
            - pkg: haproxy
        - watch_in:
            - service: consul-template-service


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
            parameters: >
                --has smartstack:external
                --open-iptables=conntrack
                --smartstack-localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
                {% if 'ssl' in pillar and 'maincert' in pillar['ssl'] -%}
                -D maincert={{pillar['ssl']['default-cert-full']}}
                {%- endif %}
            template: /etc/haproxy/haproxy-external.jinja.cfg
        - require:
            - file: haproxy-config-template-external
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@external
        - require:
            - file: haproxy-multi
            - file: smartstack-external
            {% if 'ssl' in pillar and 'maincert' in pillar['ssl'] %}
            - file: ssl-maincert
            {% endif %}


smartstack-ensure-iptables-rules:
    cmd.run:
        - name: >
            /etc/consul/renders/smartstack-external.py
            --has smartstack:external
            --open-iptables=conntrack
            --smartstack-localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
            --only-iptables
        - require:
            - file: smartstack-external

# vim: syntax=yaml
