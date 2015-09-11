
apache2.2-common:
    pkg.installed


apache2-mpm-event:
    pkg.installed


libapache2-mod-xsendfile:
    pkg.installed


apache2:
    service:
        - running
        - require:
            - pkg: apache2.2-common
            - pkg: apache2-mpm-event


{% for port in ['80', '443'] %}
# allow others to contact us on ports
apache2-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# -* vim: syntax=yaml

