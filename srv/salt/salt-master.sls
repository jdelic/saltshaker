
salt-master:
    pkg.installed:
        - order: 10
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
# allow the internal network to talk to us
saltmaster-tcp-in{{port}}-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - if: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - proto: tcp
        - match: state
        - connstate: new
        # it's super important these go first so the local minion works
        - order: 2
        - save: True
{% endfor %}


# vim: syntax=yaml

