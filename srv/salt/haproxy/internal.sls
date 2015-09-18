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
        - context:
            servicescript: /etc/consul/renders/smartstack-internal.py
            target: /etc/haproxy/haproxy-smartstack.cfg
            command: systemctl reload haproxy@smartstack
            parameters: --has smartstack:internal
            template: /etc/haproxy/haproxy.jinja.cfg
        - require:
            - pkg: haproxy
            - file: consul-template-dir
            - file: consul-template-servicerenderer
    service.running:
        - name: haproxy@internal
        - sig: haproxy -f /etc/haproxy/haproxy-smartstack.cfg
        - enable: True
        - require:
            - file: haproxy-multi
            - file: smartstack-internal
            - service: consul-template-service


# vim: syntax=yaml
