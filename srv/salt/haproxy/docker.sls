# sets up a consul-template instance that configures an haproxy instance on
# the docker0 bridge so that it exposes ports for all internal network services
# registered on consul to docker containers.

include:
    - haproxy.install


smartstack-docker-runner:
    file.managed:
        - name: /etc/consul/helpers/smartstack-docker-runner.sh
        - contents: |
            #!/bin/bash
            set -e
            /usr/bin/python3 /etc/consul/renders/smartstack-docker.py \
                --include tags=smartstack:internal \
                --smartstack-localip {{pillar.get('docker', {}).get('bridge-ip', grains['ip_interfaces']['docker0'])}} \
                -D transparent_bind=1 \
                -D socketsuffix=docker \
                {%- if pillar.get("crypto", {}).get("generate-secure-dhparams", True) %}
                    -D load_dhparams=True \
                {%- endif %}
                -o  /etc/haproxy/haproxy-docker.cfg \
                -c  "ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-docker.cfg' >/dev/null && systemctl reload haproxy@docker || systemctl restart haproxy@docker" \
                /etc/haproxy/haproxy-internal.jinja.cfg
        - mode: 750
        - require:
            - file: consul-helpers-dir
            - file: haproxy-config-template-internal

smartstack-docker:
    file.managed:
        - name: /etc/consul/template.d/smartstack-docker.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-docker.py
            command: /etc/consul/helpers/smartstack-docker-runner.sh
        - require:
            - systemdunit: haproxy-multi
            - file: smartstack-docker-runner
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@docker
        - require:
            - file: smartstack-docker
        - require_in:
            - cmd: smartstack-docker-sync
