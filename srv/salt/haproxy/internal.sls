# sets up a consul-template instance that configures an haproxy instance on
# localhost so that it exposes ports for all internal network services
# registered on consul. This will provide the SmartStack interface on
# every node to talk to other internal services.

include:
    - haproxy.install


smartstack-internal:
    file.managed:
        - name: /etc/consul/template.d/smartstack-internal.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-internal.py
            target: /etc/haproxy/haproxy-internal.cfg
            # this (yaml folded) command-line will reload haproxy if it is running and restart it otherwise
            command: >
                ps awwfux | grep -v grep | grep -q 'haproxy -f /etc/haproxy/haproxy-internal.cfg' &&
                systemctl reload haproxy@internal ||
                systemctl restart haproxy@internal
            parameters: --has smartstack:internal
            template: /etc/haproxy/haproxy.jinja.cfg
        - require:
            - file: haproxy-config-template
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@internal
        - require:
            - file: haproxy-multi
            - file: smartstack-internal


# vim: syntax=yaml
