
salt-master:
    service:
        - running
        - enable: True
        - order: 2


{% for port in ['4505', '4506'] %}
    {% for proto in ['tcp', 'udp'] %}
# allow the internal network to talk to us
saltmaster-{{proto}}-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - proto: {{proto}}
        # it's super important these go first so the local minion works
        - order: 2
        - save: True


# allow us to respond to the internal network
saltmaster-{{proto}}-in{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - proto: {{proto}}
        - sport: {{port}}
        # it's super important these go first so the local minion works
        - order: 2
        - save: True
    {% endfor %}
{% endfor %}

# vim: syntax=yaml

