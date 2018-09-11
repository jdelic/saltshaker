
# This state configures consul as a cluster AGENT. It's mutually exclusive with the consul.server state.
# You can find more details in consul.install

include:
    - consul.install
    - consul.sync


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
        - require:
            - file: consul-conf-dir


consul-agent-service:
    file.managed:
        - name: /etc/systemd/system/consul.service
        - source: salt://consul/consul.jinja.service
        - template: jinja
        - context:
            user: {{consul_user}}
            group: {{consul_group}}
            extra_parameters: -retry-max=2
            node_id: {{grains['id']}}
        - require:
            - file: consul
            - file: consul-server-absent
        - unless:
            - sls: consul.server  # make consul.agent mutually exclusive with consul.server
    service.running:
        - name: consul
        - sig: consul
        - enable: True
        - init_delay: 2
        - watch:
            - file: consul-acl-config
            - file: consul-agent-service
            - file: consul-common-config
            - file: consul-agent-service  # if consul.service changes we want to *restart* (reload: False)
            - file: consul  # restart on a change of the binary
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/agent/members
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - header_dict:
            X-Consul-Token: anonymous
        - watch:
            - service: consul-agent-service
        - require_in:
            - cmd: consul-sync


consul-agent-register-acl:
    event.wait:
        - name: maurusnet/consul/installed
        - watch:
            - service: consul-agent-service
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/acl/info/{{pillar['dynamicsecrets']['consul-acl-token']}}
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - require:
            - event: consul-agent-register-acl
        - require_in:
            - cmd: consul-sync


consul-agent-service-reload:
    service.running:
        - name: consul
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - require:
            - file: consul-agent-service
        - watch:
            # If we detect a change in the service definitions reload, don't restart. This matches STATE names not FILE
            # names, so this watch ONLY works on STATES named /etc/consul/services.d/[whatever]!
            # We match on services.d with NO TRAILING SLASH because otherwise the watch prerequisite will FAIL if there
            # is no other state that matches "/etc/consul/services.d/*" whereas "/etc/consul/services.d*" will match the
            # consul.install.consul-service-dir state.
            - file: /etc/consul/services.d*
            - file: consul-common-config
        - watch_in:
            - service: pdns-recursor-service


consul-server-absent:
    file.absent:
        - name: /etc/systemd/system/consul-server.service
        - require:
            - service: consul-server-absent
    service.dead:
        - name: consul-server
        - sig: consul
        - enable: False


# vim: syntax=yaml
