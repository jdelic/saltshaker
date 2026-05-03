
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


haproxy-acme-dump-script:
    file.managed:
        - name: /usr/local/sbin/haproxy-dump-acme-certs
        - source: salt://haproxy/haproxy-dump-acme-certs.py
        - user: root
        - group: root
        - mode: '0755'


haproxy-acme-dump-service:
    systemdunit.managed:
        - name: /etc/systemd/system/haproxy-acme-dump.service
        - source: salt://haproxy/haproxy-acme-dump.service
        - template: jinja
        - context:
            socket_path: {{pillar.get('haproxy', {}).get('acme-dump-socket', '/run/haproxy/admin-external.sock')}}
            cert_dir: {{pillar.get('haproxy', {}).get('acme-cert-dir', '/etc/haproxy/acme/certs')}}
        - require:
            - file: haproxy-acme-dump-script


haproxy-acme-dump-timer-unit:
    file.managed:
        - name: /etc/systemd/system/haproxy-acme-dump.timer
        - source: salt://haproxy/haproxy-acme-dump.timer


haproxy-acme-dump-timer:
    service.running:
        - name: haproxy-acme-dump.timer
        - enable: True
        - require:
            - file: haproxy-acme-dump-timer-unit
            - systemdunit: haproxy-acme-dump-service


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
                /usr/local/sbin/haproxy-dump-acme-certs --quiet
                --ignore-missing-socket
                --socket {{pillar.get('haproxy', {}).get('acme-dump-socket', '/run/haproxy/admin-external.sock')}}
                --cert-dir {{pillar.get('haproxy', {}).get('acme-cert-dir', '/etc/haproxy/acme/certs')}} || true;
                ps awwfux | grep -v grep | grep 'haproxy -f /etc/haproxy/haproxy-external.cfg' >/dev/null &&
                systemctl reload haproxy@external ||
                systemctl restart haproxy@external
            parameters: >
                --include tags=smartstack:external
                --open-nftables=conntrack
                --ensure-acme-placeholder-certs
                --acme-cert-dir {{pillar.get('haproxy', {}).get('acme-cert-dir', '/etc/haproxy/acme/certs')}}
                {%- for ip in haproxy_ips -%}
                    {{' '}}--smartstack-localip {{ip}}
                {%- endfor %}
                {{' '}}-D acme_directory={{pillar.get('haproxy', {}).get('acme-directory', 'https://acme-v02.api.letsencrypt.org/directory')}}
                {{' '}}-D acme_account_key={{pillar.get('haproxy', {}).get('acme-account-key', '/etc/haproxy/acme/letsencrypt.account.key')}}
                {%- if pillar.get('haproxy', {}).get('acme-contact', None) -%}
                    {{' '}}-D acme_contact={{pillar['haproxy']['acme-contact']}}
                {%- endif %}
                {%- if pillar.get('ssl', {}).get('sources', {}).get('default', {}).get('full', None) and
                      salt['pillar.fetch'](pillar['ssl']['sources']['default']['full'], None) -%}
                    {{' '}}-D certfolder={{pillar['ssl']['secret-key-location']}}
                {%- endif %}
                {%- if pillar.get("crypto", {}).get("generate-secure-dhparams", True) -%}
                    {{' '}}-D load_dhparams=True
                {%- endif %}
            template: /etc/haproxy/haproxy-external.jinja.cfg
        - require:
            - systemdunit: haproxy-multi
            - systemdunit: haproxy-acme-dump-service
            - file: haproxy-config-template-external
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
