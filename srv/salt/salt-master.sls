
salt-master:
    pkg.installed:
        - order: 2
        - require:
            - pkgrepo: saltstack-repo
    service:
        - running
        - enable: True
        - require:
            - pkg: salt-master


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
saltmaster-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/salt
        - target: /etc/salt
{% endif %}

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

