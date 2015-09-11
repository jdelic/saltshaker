# TODO:
# create a consul-template instance that configures an haproxy instance on
# localhost so that it exposes ports for all internal network services
# registered on consul. This will provide the SmartStack interface on
# every node to talk to other internal services.

include:
    - haproxy.install


smartstack-internal:
    file.managed:
        - name: /etc/haproxy/
        - require:
            - pkg: haproxy

# vim: syntax=yaml
