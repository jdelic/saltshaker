#
# BASICS: salt-minion is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#


salt-minion:
    pkg.installed:
        - require:
            - pkgrepo: saltstack-repo
    service:
        - running
        - enable: True
        - require:
            - pkg: salt-minion


{% for port in ['4505', '4506'] %}
    {% for proto in ['tcp', 'udp'] %}
# allow the saltmaster on the internal network to talk to us
saltminion-{{proto}}-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - sport: {{port}}
        - proto: {{proto}}
        # it's super important these go first so the local minion works, static order 2 is compatible with iptables.init
        - order: 2
        - save: True


# allow us to talk to the saltmaster on the internal network
saltminion-{{proto}}-in{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - proto: {{proto}}
        - dport: {{port}}
        # it's super important these go first so the local minion works, static order 2 is compatible with iptables.init
        - order: 2
        - save: True
    {% endfor %}
{% endfor %}


# vim: syntax=yaml

