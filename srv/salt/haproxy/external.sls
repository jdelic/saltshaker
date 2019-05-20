
include:
    - haproxy.install
    - haproxy.sync


haproxy-config-template-external:
    file.managed:
        - name: /etc/haproxy/haproxy-external.jinja.cfg
        - source: salt://haproxy/haproxy-external.jinja.cfg
        - require:
            - pkg: haproxy
        - onchanges_in:
            - cmd: consul-template-servicerenderer


smartstack-external:
    file.managed:
        - name: /etc/consul/template.d/smartstack-external.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-external.py
            target: /etc/haproxy/haproxy-external.cfg
            # this (yaml folded) command-line will reload haproxy if it is running and restart it otherwise
            # don't use "grep -q" since it will lead to a "broken pipe" error when called through Python
            # subprocess. Instead redirect unnecessary output into /dev/null.
            command: >
                ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-external.cfg' >/dev/null &&
                systemctl reload haproxy@external ||
                systemctl restart haproxy@external
            parameters: >
                --include tags=smartstack:external
                --open-iptables=conntrack
                --smartstack-localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
                {%- if pillar.get('ssl', {}).get('sources', {}).get('default-cert', None) and
                      salt['pillar.fetch'](pillar['ssl']['sources']['default-cert'], None) -%}
                    {{' '}}-D maincert={{pillar['ssl']['filenames']['default-cert-full']}}
                {%- endif %}
                {%- if pillar.get("crypto", {}).get("generate-secure-dhparams", True) -%}
                    {{' '}}-D load_dhparams=True
                {%- endif %}
            template: /etc/haproxy/haproxy-external.jinja.cfg
        - require:
            - systemdunit: haproxy-multi
            - file: haproxy-config-template-external
            - file: consul-template-dir
    service.enabled:  # haproxy will be started by the smartstack script rendered by consul-template (see command above)
        - name: haproxy@external
        - require:
            - file: smartstack-external
            {% if 'ssl' in pillar and 'maincert' in pillar['ssl'] %}
            - file: ssl-maincert
            {% endif %}
        - require_in:
            - cmd: smartstack-external-sync


# This is probably overkill, since consul-template already runs the smartstack script with --open-iptables=conntrack
#smartstack-ensure-iptables-rules:
#    cmd.run:
#        - name: >
#            /etc/consul/renders/smartstack-external.py
#            --include tags=smartstack:external
#            --open-iptables=conntrack
#            --smartstack-localip {{pillar.get('loadbalancer', {}).get('external-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get('external-ip-index', 0)|int()])}}
#            --only-iptables
#        - require:
#            - file: smartstack-external

# vim: syntax=yaml
