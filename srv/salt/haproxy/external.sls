
include:
    - haproxy.install
    - haproxy.sync
    - consul.sync


haproxy-config-template-external:
    file.managed:
        - name: /etc/haproxy/haproxy-external.jinja.cfg
        - source: salt://haproxy/haproxy-external.jinja.cfg
        - require:
            - pkg: haproxy
        - onchanges_in:
            - cmd: consul-template-servicerenderer


{% set haproxy_ips = [] %}
{% set x = haproxy_ips.append(
               pillar.get('haproxy', {}).get('override-ipv4',
                   grains['ip4_interfaces'].get(pillar['ifassign']['external'], {})[pillar['ifassign'].get('external-ip-index', 0)|int()])
           ) if pillar.get('haproxy', {}).get('bind-ipv4', False) %}
{% if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 %}
    {% set x = haproxy_ips.append(
                   pillar.get('haproxy', {}).get('override-ipv6',
                       salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                           pillar['ifassign-ipv6'].get('external-ipv6-suffix', "1")
                   )
               ) if pillar.get('haproxy', {}).get('bind-ipv6', False) %}
{% endif %}
smartstack-external-runner:
    file.managed:
        - name: /etc/consul/helpers/smartstack-external-runner.sh
        - contents: |
            #!/bin/bash
            set -e
            /usr/bin/python3 /etc/consul/renders/smartstack-external.py \
                --include 'tags=smartstack:external,tags=regex=smartstack:routing:(.*)' \
                --include 'tags=smartstack:external,tags=regex=smartstack:proxypath:(.*)' \
                --open-nftables=conntrack \
                {%- for ip in haproxy_ips %}
                    {{' '}}--smartstack-localip {{ip}} \
                {%- endfor %}
                {%- if pillar.get('ssl', {}).get('sources', {}).get('default', {}).get('full', None) and
                        salt['pillar.fetch'](pillar['ssl']['sources']['default']['full'], None) %}
                    {{' '}}-D certfolder={{pillar['ssl']['secret-key-location']}} \
                {%- endif %}
                {%- if pillar.get("crypto", {}).get("generate-secure-dhparams", True) %}
                    {{' '}}-D load_dhparams=True \
                {%- endif %}
                -o  /etc/haproxy/haproxy-external.cfg \
                -c  "ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-external.cfg' >/dev/null && systemctl reload haproxy@external || systemctl restart haproxy@external" \
                /etc/haproxy/haproxy-external.jinja.cfg
        - mode: 750
        - require:
            - file: consul-helpers-dir
            - file: haproxy-config-template-external


smartstack-external:
    file.managed:
        - name: /etc/consul/template.d/smartstack-external.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-external.py
            command: /etc/consul/helpers/smartstack-external-runner.sh
        - require:
            - systemdunit: haproxy-multi
            - file: smartstack-external-runner
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@external
        - require:
            - file: smartstack-external
            {% if pillar.get('ssl', {}).get('sources', {}).get('default', {}).get('full', None) and
                  salt['pillar.fetch'](pillar['ssl']['sources']['default']['full'], None) %}
            - file: ssl-certificate-default-full
            {% endif %}
        - require_in:
            - cmd: smartstack-external-sync


# This is probably overkill, since consul-template already runs the smartstack script with --open-nftables=conntrack
smartstack-ensure-nftables-rules:
    cmd.run:
        - name: >
            for i in $(seq 1 10); do
                test -x /etc/consul/renders/smartstack-external.py && break;
                sleep 1;
            done;
            /etc/consul/renders/smartstack-external.py
            --include tags=smartstack:external
            --open-nftables=conntrack
            --smartstack-localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
            --only-nftables
        - require:
            - file: smartstack-external
            - cmd: consul-template-sync
        - require_in:
            - cmd: smartstack-external-sync


# vim: syntax=yaml
