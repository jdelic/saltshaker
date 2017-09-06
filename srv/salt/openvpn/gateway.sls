# install a openvpn server that routes all traffic to the internet

include:
    - openvpn.install


{% if pillar.get('openvpn', {}).get('sslcert', 'default') != 'default' %}
openvpn-gateway-ssl-cert:
    file.managed:
        - name: {{pillar['openvpn']['sslcert']}}
        - contents_pillar: {{pillar['openvpn']['sslcert-contents']}}
        - mode: 440
        - user: root
        - group: root
        - require:
            - file: ssl-cert-location


openvpn-gateway-ssl-key:
    file.managed:
        - name: {{pillar['openvpn']['sslkey']}}
        - contents_pillar: {{pillar['openvpn']['sslkey-contents']}}
        - mode: 400
        - user: root
        - group: root
        - require:
            - file: ssl-key-location
{% endif %}


openvpn-udp-gateway-conf:
    file.managed:
        - name: /etc/openvpn/server/gateway-udp.conf
        - source: salt://openvpn/gateway.jinja.conf
        - template: jinja
        - context:
            server_ip: >
                {{pillar.get('openvpn', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                        'external-ip-index', 0
                    )|int()]
                )}}
            server_port: 1194
            proto: udp
            basenet: 10.0.254.0
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


openvpn-tcp-gateway-conf:
    file.managed:
        - name: /etc/openvpn/server/gateway-tcp.conf
        - source: salt://openvpn/gateway.jinja.conf
        - template: jinja
        - context:
            server_ip: >
                {{pillar.get('openvpn', {}).get('bind-ip',
                    grains['ip_interfaces'][pillar['ifassign']['external']][pillar['ifassign'].get(
                        'external-ip-index', 0
                    )|int()]
                )}}
            server_port: 1194
            proto: tcp
            basenet: 10.0.253.0
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


openvpn-config-folder:
    file.directory:
        - name: /etc/openvpn/server
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


# create our own dhparams for more SSL security
openvpn-dhparams:
    cmd.run:
        - name: openssl dhparam -out /etc/openvpn/server/dhparams.pem 2048
        - creates: /etc/openvpn/server/dhparams.pem
        - require:
            - file: openvpn-config-folder


# keys for additional security during TLS negotation, should be rotated every 8192 years divided by the number
# of users that share the same key
openvpn-tls-crypt-key:
    cmd.run:
        - name: openvpn --genkey --secret /etc/openvpn/server/tls-preshared-crypt.key
        - creates: /etc/openvpn/server/tls-preshared-crypt.key
        - require:
            - file: openvpn-config-folder


openvpn-udp-service:
    service.running:
        - name: openvpn-server@gateway-udp
        - sig: openvpn-server/status-gateway-udp
        - enable: True
        - watch:
            - file: openvpn-udp-gateway-conf
            - cmd: openvpn-dhparams
            - cmd: openvpn-tls-crypt-key
{% if pillar.get('openvpn', {}).get('sslcert', 'default') != 'default' %}
            - file: openvpn-gateway-ssl-cert
            - file: openvpn-gateway-ssl-key
{% endif %}
        - require:
            - pkg: openvpn


openvpn-tcp-service:
    service.running:
        - name: openvpn-server@gateway-tcp
        - sig: openvpn-server/status-gateway-tcp
        - enable: True
        - watch:
            - file: openvpn-tcp-gateway-conf
            - cmd: openvpn-dhparams
            - cmd: openvpn-tls-crypt-key
{% if pillar.get('openvpn', {}).get('sslcert', 'default') != 'default' %}
            - file: openvpn-gateway-ssl-cert
            - file: openvpn-gateway-ssl-key
{% endif %}
        - require:
            - pkg: openvpn


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


openvpn-clients-nat:
    iptables.append:
        - table: nat
        - chain: POSTROUTING
        - jump: MASQUERADE
        - source: 10.0.254.0/24
        - destination: '0/0'
        - save: True
        - require:
            - sls: iptables
