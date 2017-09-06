# install a openvpn server

openvpn:
    pkg.installed:
        - install_recommends: False


openvpn-traffic-conf:
    file.managed:
        - name: /etc/openvpn/server/traffic.conf
        - source: salt://openvpn/traffic.jinja.conf
        - template: jinja
        - context:
            server_ip: >
                {{pillar.get('openvpn', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                        'external-ip-index', 0
                    )|int()]
                )}}
            server_port: 1194
            capath: {{pillar['ssl']['service-rootca-cert']}}
            servercert: >
                {%- if pillar.get('openvpn', {}).get('sslcert', 'default') == 'default' %}
                    {{pillar['ssl']['filenames']['default-cert-combined']}}
                {%- else %}
                    {{pillar['openvpn']['sslcert']}}
                {%- endif %}
            servercertkey: >
                {%- if pillar.get('openvpn', {}).get('sslcert', 'default') == 'default' %}
                    {{pillar['ssl']['filenames']['default-cert-key']}}
                {%- else %}
                    {{pillar['openvpn']['sslkey']}}
                {%- endif %}
        - require:
            - pkg: openvpn
            - file: {{pillar['ssl']['service-rootca-cert']}}


# create our own dhparams for more SSL security
openvpn-dhparams:
    file.directory:
        - name: /etc/openvpn/server
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
    cmd.run:
        - name: openssl dhparam -out /etc/openvpn/server/dhparams.pem 2048
        - creates: /etc/openvpn/server/dhparams.pem
        - require:
            - file: openvpn-dhparams


openvpn-service:
    service.running:
        - name: openvpn-server@traffic
        - watch:
            - file: openvpn-traffic-conf
        - require:
            - pkg: openvpn
            - cmd: openvpn-dhparams


# allow others to contact us
openvpn-tcp-in1194-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar.get('openvpn', {}).get(
            'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                'external-ip-index', 0
            )|int()]
        )}}
        - dport: 1194
        - proto: tcp
        - match: state
        - connstate: NEW
        - save: True
        - require:
            - sls: iptables


openvpn-udp-in1194-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{pillar.get('openvpn', {}).get(
            'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                'external-ip-index', 0
            )|int()]
        )}}
        - dport: 1194
        - proto: udp
        - save: True
        - require:
            - sls: iptables


openvpn-udp-in1194-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - source: {{pillar.get('openvpn', {}).get(
            'bind-ip', grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                'external-ip-index', 0
            )|int()]
        )}}
        - destination: '0/0'
        - sport: 1194
        - proto: udp
        - save: True
        - require:
            - sls: iptables
