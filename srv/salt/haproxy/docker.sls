# sets up a consul-template instance that configures an haproxy instance on
# the docker0 bridge so that it exposes ports for all internal network services
# registered on consul to docker containers.

include:
    - haproxy.install


smartstack-docker:
    file.managed:
        - name: /etc/consul/template.d/smartstack-docker.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-docker.py
            target: /etc/haproxy/haproxy-docker.cfg
            # this (yaml folded) command-line will reload haproxy if it is running and restart it otherwise
            # don't use "grep -q" since it will lead to a "broken pipe" error when called through Python
            # subprocess. Instead redirect unnecessary output into /dev/null.
            command: >
                ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-docker.cfg' >/dev/null &&
                systemctl reload haproxy@docker ||
                systemctl restart haproxy@docker
            # the escaping of localip is necessary for the consul-template command="" stanza
            parameters: >
                --include tags=smartstack:internal
                --smartstack-localip {{pillar.get('docker', {}).get('bridge-ip', grains['ip_interfaces']['docker0'])}}
                -D transparent_bind=1
                {% if pillar.get("crypto", {}).get("generate-secure-dhparams", True) -%}
                    -D load_dhparams=True
                {%- endif %}
            template: /etc/haproxy/haproxy-internal.jinja.cfg
        - require:
            - systemdunit: haproxy-multi
            - file: haproxy-config-template-internal
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@docker
        - require:
            - file: smartstack-docker
        - require_in:
            - cmd: smartstack-docker-sync
