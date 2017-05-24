
# This state configures consul as a cluster SERVER. It's mutually exclusive with the consul.agent state.
# You can find more details in consul.install

include:
    - consul.install


{% from 'consul/install.sls' import consul_user, consul_group %}


consul-acl-config:
    file.managed:
        - name: /etc/consul/conf.d/acl.json
        - source: salt://consul/acl/acl.jinja.json
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0600'
        - template: jinja
        - context:
            # make sure to change this for multi-datacenter deployments
            main_datacenter: {{pillar['consul-cluster']['datacenter']}}
            master_token: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
            agent_master_token: {{pillar['dynamicsecrets']['consul-agent-master-token']}}
        - require:
            - file: consul-conf-dir


consul-policy-dir:
    file.directory:
        - name: /etc/consul/policies.d
        - user: {{consul_user}}
        - group: {{consul_user}}
        - mode: '0750'
        - require:
            - file: consul-basedir


{% for fn in ["anonymous.jinja.json"] %}
consul-policy-{{loop.index}}:
    file.managed:
        - name: /etc/consul/policies.d/{{fn|replace('.jinja', '')}}
        - source: salt://consul/acl/{{fn}}
        - template: jinja
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0640'
        - require:
            - file: consul-policy-dir
{% endfor %}


consul-acl-token-envvar:
    file.managed:
        - name: /etc/consul/operator_token_envvar
        - contents: |
            CONSUL_HTTP_TOKEN="{{pillar['dynamicsecrets']['consul-master-token']}}"
        - user: root
        - group: root
        - mode: '0640'
        - require:
            - file: consul-basedir


consul-server-service:
    file.managed:
        - name: /etc/systemd/system/consul-server.service
        - source: salt://consul/consul.jinja.service
        - template: jinja
        - context:
            user: {{consul_user}}
            group: {{consul_group}}
            extra_parameters: -server -bootstrap-expect={{pillar['consul-cluster']['number-of-nodes']}} -ui
            single_node_cluster: {% if pillar['consul-cluster']['number-of-nodes'] == 1 %}True{% else %}False{% endif %}
        - require:
            - file: consul
            - file: consul-agent-absent
        - unless:
            - sls: consul.agent
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - init_delay: 1
        - watch:
            - file: consul-server-service  # if consul.service changes we want to *restart* (reload: False)
            - file: consul  # restart on a change of the binary


{% if pillar['consul-cluster']['number-of-nodes'] == 1 %}
consul-singlenode-snapshot-timer:
    file.managed:
        - name: /etc/systemd/system/consul-snapshot.timer
        - source: salt://consul/consul-snapshot.timer


consul-singlenode-snapshort-service:
    file.managed:
        - name: /etc/systemd/system/consul-snapshot.service
        - source: salt://consul/consul-snapshot.service
    service.running:
        - name: consul-snapshot.timer
        - require:
            - file: consul-singlenode-snapshot-timer
            - file: consul-singlenode-snapshort-service
            - service: consul-server-service
{% endif %}


consul-server-service-reload:
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - init_delay: 1
        - require:
            - file: consul-server-service
        - watch:
            # If we detect a change in the service definitions reload, don't restart. This matches STATE names not FILE
            # names, so this watch ONLY works on STATES named /etc/consul/services.d/[whatever]!
            # We match on services.d with NO TRAILING SLASH because otherwise the watch prerequisite will FAIL if there
            # is no other state that matches "/etc/consul/services.d/*" whereas "/etc/consul/services.d*" will match the
            # consul.install.consul-service-dir state.
            - file: /etc/consul/services.d*
            - file: consul-common-config
            - file: consul-acl-config


consul-agent-absent:
    file.absent:
        - name: /etc/systemd/system/consul.service
        - require:
            - service: consul-agent-absent
    service.dead:
        - name: consul
        - sig: consul
        - enable: False


# vim: syntax=yaml
