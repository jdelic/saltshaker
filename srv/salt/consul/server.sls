
# This state configures consul as a cluster SERVER. It's mutually exclusive with the consul.agent state.
# You can find more details in consul.install

include:
    - consul.install


{% from 'consul/install.sls' import consul_user, consul_group %}


consul-server-service:
    file.managed:
        - name: /etc/systemd/system/consul-server.service
        - source: salt://consul/consul.jinja.service
        - template: jinja
        - context:
            user: {{consul_user}}
            group: {{consul_group}}
            extra_parameters: -server -bootstrap-expect={{pillar['consul-cluster']['number-of-nodes']}} -ui
        - require:
            - file: consul
            - file: consul-agent-absent
        - unless:
            - sls: consul.agent
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - require:
            - file: consul-server-service
        - watch:
            - file: consul-server-service  # if consul.service changes we want to *restart* (reload: False)
            - file: consul  # restart on a change of the binary


consul-server-service-reload:
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
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


consul-agent-absent:
    file.absent:
        - name: /etc/systemd/system/consul.service
        - require:
            - service: consul-agent-absent
    service.dead:
        - name: consul
        - sig: consul
        - enable: False


#consul-web-ui:
#    archive.extracted:
#        - name: /srv/consul-web-ui
#        - source: {{pillar["urls"]["consul-webui"]}}
#        - source_hash: {{pillar["hashes"]["consul-webui"]}}
#        - archive_format: zip
#        - if_missing: /srv/consul-web-ui/dist

# vim: syntax=yaml
