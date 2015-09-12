
# This state configures consul as a cluster AGENT. It's mutually exclusive with the consul.server state.
# You can find more details in consul.install

include:
    - consul.install


{% from 'consul/install.sls' import consul_user, consul_group %}


consul-agent:
    file.managed:
        - name: /etc/systemd/system/consul.service
        - source: salt://consul/consul.jinja.service
        - template: jinja
        - context:
            user: {{consul_user}}
            group: {{consul_group}}
            extra_parameters: -retry-max=2
        - require:
            - file: consul
            - file: consul-server-absent
        - unless:
            - sls: consul.server  # make consul.agent mutually exclusive with consul.server
    service.running:
        - name: consul
        - sig: consul
        - enable: True
        - require:
            - file: consul-agent
        - watch:
            - file: consul-agent  # if consul.service changes we want to *restart* (reload: False)


consul-agent-service-reload:
    service.running:
        - name: consul
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - require:
            - file: consul-agent
        - watch:
            # If we detect a change in the service definitions reload, don't restart. This matches STATE names not FILE
            # names, so this watch ONLY works on STATES named /etc/consul/services.d/[whatever]!
            # We match on services.d with NO TRAILING SLASH because otherwise the watch prerequisite will FAIL if there
            # is no other state that matches "/etc/consul/services.d/*" whereas "/etc/consul/services.d*" will match the
            # consul.install.consul-service-dir state.
            - file: /etc/consul/services.d*


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
