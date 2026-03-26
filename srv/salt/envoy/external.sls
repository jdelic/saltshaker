include:
    - .install


envoy-config-template-external:
    file.managed:
        - name: /etc/envoy/envoy-external.jinja.yaml
        - source: salt://envoy/envoy-external.jinja.yaml
        - require:
            - file: envoy-config-dir
        - onchanges_in:
            - cmd: consul-template-servicerenderer


{% set envoy_ips = [] %}
{% set x = envoy_ips.append(
               pillar.get('envoy', {}).get('override-ipv4',
                   grains['ip4_interfaces'].get(pillar['ifassign']['external'], {})[pillar['ifassign'].get('external-ip-index', 0)|int()])
           ) if pillar.get('envoy', {}).get('bind-ipv4', False) %}
{% if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 %}
    {% set x = envoy_ips.append(
                   pillar.get('envoy', {}).get('override-ipv6',
                       salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
                           pillar['ifassign-ipv6'].get('external-ipv6-suffix', "1")
                   )
               ) if pillar.get('envoy', {}).get('bind-ipv6', False) %}
{% endif %}
smartstack-envoy-external:
    file.managed:
        - name: /etc/consul/template.d/smartstack-external-envoy.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-external-envoy.py
            target: /etc/envoy/envoy-external.yaml
            # this (yaml folded) command-line will reload envoy if it is running and restart it otherwise
            # don't use "grep -q" since it will lead to a "broken pipe" error when called through Python
            # subprocess. Instead, redirect unnecessary output into /dev/null.
            command: >
                ps awwfux | grep -v grep | grep 'envoy -c /etc/envoy/envoy-external.yaml' >/dev/null &&
                systemctl reload envoy@external ||
                systemctl restart envoy@external
            parameters: >
                --include tags=smartstack:external
                --open-nftables=conntrack
                {%- for ip in envoy_ips -%}
                    {{' '}}--smartstack-localip {{ip}}
                {%- endfor %}
            template: /etc/envoy/envoy-external.jinja.yaml
        - require:
            - systemdunit: envoy-multi
            - file: envoy-config-template-external
            - file: consul-template-dir
    service.enabled:  # envoy will be started by the smartstack script rendered by consul-template (see command above)
        - name: envoy@external
        - require:
            - file: smartstack-envoy-external
        - require_in:
            - cmd: smartstack-external-sync
