# this state creates a routing script that allows VPN clients to access this node

{% if salt['mine.get']('roles:vpngateway', 'internal_ip', tgt_type='grain').items() %}
openvpn-allow-access-through-gateway:
    file.managed:
        - name: /etc/network/if-up.d/openvpn-gateway
        - contents: |
            #!/bin/bash

            if [ "$MODE" != start ]; then
                exit 0;
            fi

            if [ "$IFACE" != "{{pillar['ifassign']['internal']}}" ]; then
                exit 0;
            fi

            {% for net in ['10.0.253.0', '10.0.254.0'] %}
            if ! ip route | grep -q "{{net}}"; then
                {% for server, addr in salt['mine.get']('roles:vpngateway', 'internal_ip', tgt_type='grain').items() %}
                    ip route add {{net}}/24 via {{addr}}
                {% endfor %}
            fi
            {% endfor %}
        - user: root
        - group: root
        - mode: '0755'
    cmd.run:
        - name: /etc/network/if-up.d/openvpn-gateway
        - onchanges:
            - file: openvpn-allow-access-through-gateway
        - env:
            - IFACE: {{pillar['ifassign']['internal']}}
            - MODE: start
{% endif %}
