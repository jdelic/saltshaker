#
# Install Hashicorp's nomad Docker-based cluster manager from a .zip file and join it to the
# system-wide consul network.
#
# Nomad will be started as a server node if the nomad:is-server pillar is set.
#


{% set nomad_user = "nomad" %}
{% set nomad_group = "nomad" %}

nomad-data-dir:
    file.directory:
        - name: /var/lib/nomad
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad
            - group: nomad


nomad-pidfile-dir:
    file.directory:
        - name: /run/nomad
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad
            - group: nomad


nomad-pidfile-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/nomad.conf
        - source: salt://nomad/nomad.tmpfiles.conf
        - template: jinja
        - context:
            user: {{nomad_user}}
            group: {{nomad_group}}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - user: nomad  # the user is required in the .conf file
            - group: nomad


nomad-basedir:
    file.directory:
        - name: /etc/nomad
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


nomad-service-dir:
    file.directory:
        - name: /etc/nomad/services.d
        - makedirs: True
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - mode: '0755'
        - require:
            - user: nomad
            - group: nomad
            - file: nomad-basedir


nomad:
    group.present:
        - name: {{nomad_group}}
    user.present:
        - name: {{nomad_user}}
        - gid: {{nomad_group}}
        - groups:
            - docker
        - createhome: False
        - home: /var/lib/nomad
        - shell: /bin/sh
        - require:
             - group: nomad
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["nomad"]}}
        - source_hash: {{pillar["hashes"]["nomad"]}}
        - archive_format: zip
        - if_missing: /usr/local/bin/nomad
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/nomad
        - mode: '0755'
        - user: {{nomad_user}}
        - group: {{nomad_group}}
        - replace: False
        - require:
            - user: nomad
            - file: nomad-pidfile-dir
            - file: nomad-data-dir
            - archive: nomad
            - sls: docker


{% set internal_ip = grains['ip_interfaces'][pillar['ifassign']['internal']][
                        pillar['ifassign'].get('internal-ip-index', 0)|int()] %}


nomad-agent-config:
    file.managed:
        - name: /etc/nomad/agent.hcl
        - source: salt://nomad/agent.hcl
        - template: jinja
        - context:
            datacenter: {{pillar['consul-cluster'].get('datacenter', 'default')}}
            # TODO: fix this when nomad 0.6 comes out with better network management
            internal_interface: {{pillar['ifassign']['internal']}}
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
        - require:
            - file: nomad-service-dir


nomad-service:
    file.managed:
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
        - require:
            - file: nomad-service
            - file: nomad-server-config
            - file: nomad-agent-config
            - file: nomad-common-config
        - watch:
            - file: nomad-service  # if consul.service changes we want to *restart* (reload: False)
            - file: nomad  # restart on a change of the binary


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
