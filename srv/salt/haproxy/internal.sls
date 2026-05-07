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


smartstack-internal-runner:
    file.managed:
        - name: /etc/consul/helpers/smartstack-internal-runner.sh
        - contents: |
            #!/bin/bash
            set -e
            /usr/bin/python3 /etc/consul/renders/smartstack-internal.py \
                --include tags=smartstack:internal \
                {% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) -%}
                      -D load_dhparams=True \
                {%- endif %}
                -o  /etc/haproxy/haproxy-internal.cfg \
                -c  "ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-internal.cfg' >/dev/null && systemctl reload haproxy@internal || systemctl restart haproxy@internal" \
                /etc/haproxy/haproxy-internal.jinja.cfg
        - mode: 750
        - require:
            - file: consul-helpers-dir
            - file: haproxy-config-template-internal


smartstack-internal:
    file.managed:
        - name: /etc/consul/template.d/smartstack-internal.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-internal.py
            command: /etc/consul/helpers/smartstack-internal-runner.sh
        - require:
            - systemdunit: haproxy-multi
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@internal
        - require:
            - file: smartstack-internal
        - require_in:
            - cmd: smartstack-internal-sync


# vim: syntax=yaml
