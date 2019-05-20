# sets up a consul-template instance that configures an haproxy instance on
# localhost so that it exposes ports for all internal network services
# registered on consul. This will provide the SmartStack interface on
# every node to talk to other internal services.

include:
    - haproxy.install
    - haproxy.sync


haproxy-config-template-internal:
    file.managed:
        - name: /etc/haproxy/haproxy-internal.jinja.cfg
        - source: salt://haproxy/haproxy-internal.jinja.cfg
        - require:
            - pkg: haproxy
        - onchanges_in:
            - cmd: consul-template-servicerenderer


smartstack-internal:
    file.managed:
        - name: /etc/consul/template.d/smartstack-internal.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-internal.py
            target: /etc/haproxy/haproxy-internal.cfg
            # this (yaml folded) command-line will reload haproxy if it is running and restart it otherwise
            # don't use "grep -q" since it will lead to a "broken pipe" error when called through Python
            # subprocess. Instead redirect unnecessary output into /dev/null.
            command: >
                ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-internal.cfg' >/dev/null &&
                systemctl reload haproxy@internal ||
                systemctl restart haproxy@internal
            parameters: >
                --include tags=smartstack:internal
                {% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) -%}
                    -D load_dhparams=True
                {%- endif %}
            template: /etc/haproxy/haproxy-internal.jinja.cfg
        - require:
            - systemdunit: haproxy-multi
            - file: haproxy-config-template-internal
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@internal
        - require:
            - file: smartstack-internal
        - require_in:
            - cmd: smartstack-internal-sync


# vim: syntax=yaml
