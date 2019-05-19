#
# Nomad will be started as a server node if the nomad:is-server pillar is set.
#

include:
    - nomad.client
    - docker.install


{% from 'nomad/client.sls' import nomad_user, nomad_group %}

{% set internal_ip = grains['ip_interfaces'][pillar['ifassign']['internal']][
                        pillar['ifassign'].get('internal-ip-index', 0)|int()] %}


nomad-docker-group-membership:
    user.present:
        - name: {{nomad_user}}
        - groups:
            - docker
        - require:
             - sls: docker.install
             - user: nomad-user


nomad-agent-config:
    file.managed:
        - name: /etc/nomad/agent.hcl
        - source: salt://nomad/agent.hcl
        - template: jinja
        - context:
            datacenter: {{pillar['consul-cluster'].get('datacenter', 'default')}}
            # TODO: fix this when nomad 1.0 comes out with better network management
            internal_interface: {{pillar['ifassign']['internal']}}
            consul_acl_token: {{pillar['dynamicsecrets']['consul-acl-token']['secret_id']}}
        - require:
            - file: nomad-service-dir


nomad-server-config:
    file.managed:
        - name: /etc/nomad/server.hcl
        - source: salt://nomad/server.hcl
        - template: jinja
        - context:
            bootstrap_expect: {{pillar['nomad-cluster']['number-of-servers']}}
        - require:
            - file: nomad-service-dir


nomad-common-config:
    file.managed:
        - name: /etc/nomad/common.hcl
        - source: salt://nomad/common.hcl
        - template: jinja
        - context:
            internal_ip: {{internal_ip}}
            # only enable the http update check if the value of the pillar is exactly 'true'
            # it's always better to not leak usage data and IPs to Hashicorp.
            disable_update_check: >
                {% if pillar['nomad-cluster'].get('check-for-updates', 'false')|lower == 'true' -%}
                    false
                {%- else -%}
                    true
                {%- endif %}
        - require:
            - file: nomad-service-dir


nomad-service:
    systemdunit.managed:
        - name: /etc/systemd/system/nomad.service
        - source: salt://nomad/nomad.jinja.service
        - template: jinja
        - context:
            user: {{nomad_user}}
            group: {{nomad_group}}
            parameters: >
                -config=/etc/nomad/common.hcl
                {% if pillar.get('nomad-cluster', {}).get('is-server', False) -%}
                    -config=/etc/nomad/server.hcl
                {% endif -%}
                -config=/etc/nomad/agent.hcl
        - require:
            - file: nomad
    service.running:
        - name: nomad
        - sig: nomad
        - enable: True
        - watch:
            - systemdunit: nomad-service  # if nomad-service changes we want to *restart* (reload: False)
            - file: nomad  # restart on a change of the binary
            - file: nomad-server-config
            - file: nomad-agent-config
            - file: nomad-common-config


# open nomad ports TCP https://www.nomadproject.io/docs/cluster/requirements.html
{% for port in ['4646', '4647', '4648'] %}
# allow others to talk to us
nomad-tcp-in{{port}}-recv:
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
nomad-tcp-out{{port}}-send:
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


nomad-udp-in4648-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 4648
        - proto: udp
        - save: True
        - require:
            - sls: iptables


nomad-udp-in4648-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - sport: 4648
        - proto: udp
        - save: True
        - require:
            - sls: iptables


nomad-envvar-config:
    file.managed:
        - name: /etc/profile.d/nomadclient.sh
        - contents: |
            export NOMAD_ADDR="http://{{internal_ip}}:4646/"
        - user: root
        - group: root
        - mode: '0644'
