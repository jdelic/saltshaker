#
# Installs Hashicorp Consul in /usr/local/bin from a binary distribution downloaded from the Internet.
# Actual service configuration then happens by assigning the (mutually exclusive) consul.agent or consul.server
# states to a node. The provided consul.service systemd script uses the Saltstack Saltmine to find the servers
# among the salt-master's minions and adds them as cluster nodes.
#
# Bootstrapping the consul cluster is the one area where relying on the salt-master for service discovery makes
# sense. After that, well... you can use consul :).
#
# NOTE:
# This state is included from consul.agent and consul.server so there is basically never a reason where you would
# assign it to a node directly.
#

{% set consul_user = "consul" %}
{% set consul_group = "consul" %}

consul-data-dir:
    file.directory:
        - name: /run/consul
        - makedirs: True
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0755'
        - require:
            - user: consul
            - group: consul


consul-data-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/consul.conf
        - source: salt://consul/consul.tmpfiles.conf
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - user: consul  # the user is required in the .conf file
            - group: consul


consul-basedir:
    file.directory:
        - name: /etc/consul
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


consul-service-dir:
    file.directory:
        - name: /etc/consul/services.d
        - makedirs: True
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0755'
        - require:
            - user: consul
            - group: consul
            - file: consul-basedir


consul:
    group.present:
        - name: {{consul_group}}
    user.present:
        - name: {{consul_user}}
        - gid: {{consul_group}}
        - createhome: False
        - home: /etc/consul/services.d
        - shell: /bin/sh
        - require:
             - group: consul
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["consul"]}}
        - source_hash: sha256=171cf4074bfca3b1e46112105738985783f19c47f4408377241b868affa9d445
        - archive_format: zip
        - if_missing: /usr/local/bin/consul
    file.managed:
        - name: /usr/local/bin/consul
        - mode: '0755'
        - user: {{consul_user}}
        - group: {{consul_group}}
        - require:
            - user: consul
            - file: consul-data-dir


# open consul ports TCP
{% for port in ['8300', '8301', '8400', '8500', '8600'] %}
# allow others to talk to us
consul-tcp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# allow us to talk to others
consul-tcp-out{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# open consul ports UDP
{% for port in ['8301', '8600'] %}
consul-udp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - proto: udp
        - save: True
        - require:
            - sls: iptables


consul-udp-in{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - sport: {{port}}
        - proto: udp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# vim: syntax=yaml
