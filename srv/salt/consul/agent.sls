
# This state configures consul as a cluster AGENT. It's mutually exclusive with the consul.server state.
# You can find more details in consul.install

include:
    - consul.install
    - consul.sync
    - consul.acl_install


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


consul-service:
    systemdunit.managed:
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
            - file: consul-common-config
            - file: consul-acl-agent-config
            - file: consul  # restart on a change of the binary
            - systemdunit: consul-service  # if consul.service changes we want to *restart* (reload: False)
        - require:
            - cmd: consul-sync-network
    cmd.run:
        - name: >
            until
                test $(curl -s -H 'X-Consul-Token: anonymous' http://169.254.1.1:8500/v1/agent/members \
                        | jq 'length') -gt 0 || test ${count} -gt 10; do sleep 1; count=$((count+1)); done &&
                test ${count} -lt 30
        - env:
            count: 0
        - watch:
            - service: consul-service
        - require_in:
            - cmd: consul-sync


consul-service-reload:
    service.running:
        - name: consul
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - require:
            - systemdunit: consul-service  # if consul.service changes we want to *restart* (reload: False)
        - watch:
            # If we detect a change in the service definitions reload, don't restart. This matches STATE names not FILE
            # names, so this watch ONLY works on STATES named /etc/consul/services.d/[whatever]!
            # We match on services.d with NO TRAILING SLASH because otherwise the watch prerequisite will FAIL if there
            # is no other state that matches "/etc/consul/services.d/*" whereas "/etc/consul/services.d*" will match the
            # consul.install.consul-service-dir state.
            - file: /etc/consul/services.d*
            - file: consul-common-config
        - require_in:  # ensure that all service registrations happen
            - cmd: consul-sync


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
