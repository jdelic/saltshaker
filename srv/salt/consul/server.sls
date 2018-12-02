
# This state configures consul as a cluster SERVER. It's mutually exclusive with the consul.agent state.
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


consul-policy-anonymous:
    file.managed:
        - name: /etc/consul/policies.d/anonymous.json
        - source: salt://consul/acl/anonymous.jinja.json
        - template: jinja
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0640'
        - require:
            - file: consul-policy-dir


consul-update-anonymous-policy:
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/agent/members
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - header_dict:
            X-Consul-Token: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - require:
            - service: consul-server-service
    cmd.run:
        - name: >
            curl -i -s -X PUT -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" \
                --data @/etc/consul/policies.d/anonymous.json \
                http://169.254.1.1:8500/v1/acl/policy
        - env:
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - unless: consul acl policy list | grep "^anonymous" >/dev/null
        - require:
            - file: consul-policy-anonymous
            - http: consul-update-anonymous-policy
        - require_in:
            - http: consul-server-service
        - watch:
            - service: consul-server-service


consul-update-anonymous-token:
    cmd.run:
        - name: >
            curl -i -s -X PUT -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" \
                --data '{ "SecretID": "anonymous", "Policies": [{ "Name": "anonymous" }] }' \
                http://169.254.1.1:8500/v1/acl/token/00000000-0000-0000-0000-000000000002
        - env:
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - require:
            - cmd: consul-update-anonymous-policy
        - require_in:
            - http: consul-server-service
        - watch:
            - service: consul-server-service


consul-acl-token-envvar:
    file.managed:
        - name: /etc/consul/acl_token_envvar
        - contents: |
            CONSUL_HTTP_TOKEN="{{pillar['dynamicsecrets']['consul-acl-master-token']}}"
        - user: root
        - group: root
        - mode: '0640'
        - require:
            - file: consul-basedir


consul-agent-token-envvar:
    file.managed:
        - name: /etc/consul/operator_token_envvar
        - contents: |
            CONSUL_HTTP_TOKEN="{{pillar['dynamicsecrets']['consul-agent-master-token']}}"
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
            node_id: {{grains['id']}}
        - require:
            - file: consul
            - file: consul-agent-absent
        - unless:
            - sls: consul.agent
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - init_delay: 2
        - require:
            - cmd: consul-sync-network
            - file: consul-common-config
            - file: consul-server-service
            - file: consul-acl-config
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/agent/members
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - header_dict:
            X-Consul-Token: anonymous
        - require:
            - service: consul-server-service
        - require_in:
            - cmd: consul-sync


{% if pillar['dynamicsecrets']['consul-acl-token']['firstrun'] %}
# on the master server, to fix the chicken egg problem of the ACL initialization, we install the server
# and run it, then install a temporary ACL config and restart the server.
consul-tempacl-create-policy:
    cmd.run:
        - name: |+
            cat <<EOT | curl -X PUT -d @- -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" http://169.254.1.1:8500/v1/acl/policy
                {
                    "Name": "tempacl-policy-{{grains['id']|replace('.', '-')}}",
                    "Description": "Agent policy for {{grains['id']}}",
                    "Rules": "
                        key_prefix \"\" {
                            policy = \"deny\"
                        }

                        key_prefix \"oauth2-clients\" {
                            policy = \"write\"
                        }

                        node \"\" {
                            policy = \"read\"
                        }

                        node \"{{grains['id']}}\" {
                            policy = \"write\"
                        }

                        service_prefix \"\" {
                            policy = \"write\"
                        }

                        agent \"{{grains['id']}}\" {
                            policy = \"read\"
                        }

                        event_prefix \"\" {
                            policy = \"read\"
                        }

                        query_prefix \"\" {
                            policy = \"read\"
                        }
                    "
                }
            EOT
        - env:
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - unless: test -f /etc/consul/conf.d/agent_acl.json
        - require:
            - http: consul-server-service

consul-tempacl-server-config:
    cmd.run:
        - name: |+
            cat << EOT | curl -X PUT -d @- -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" http://169.254.1.1:8500/v1/acl/token/ | \
                jq -M "{acl: {tokens: { agent: .SecretID, default: .SecretID } } }" > \
                    /etc/consul/conf.d/agent_acl.json
                {
                    "Description": "Temp ACL provisioning token for {{grains['id']}}",
                    "Policies": [
                        { "Name": "tempacl-policy-{{grains['id']|replace('.', '-')}}" }
                    ]
                }
            EOT
        - creates: /etc/consul/conf.d/agent_acl.json
        - env:
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - require:
            - cmd: consul-tempacl-create-policy
        - watch_in:
            - service: consul-server-service-restart
{% else %}
# when we have a server, we run it, then
consul-server-register-acl:
    event.wait:
        - name: maurusnet/consul/installed
        - watch:
            - service: consul-server-service
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/acl/info/{{pillar['dynamicsecrets']['consul-acl-token']['accessor_id']}}
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - require:
            - event: consul-server-register-acl
        - require_in:
            - cmd: consul-sync


consul-acl-server-config:
    file.managed:
        - name: /etc/consul/conf.d/agent_acl.json
        - source: salt://consul/acl/agent_acl.jinja.json
        - user: {{consul_user}}
        - group: {{consul_group}}
        - mode: '0600'
        - template: jinja
        - context:
            agent_acl_token: {{pillar['dynamicsecrets']['consul-acl-token']['secret_id']}}
        - require:
            - http: consul-server-register-acl
        - watch_in:
            - service: consul-server-service-restart
{% endif %}


consul-server-service-restart:
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - init_delay: 2
        - watch:
            - file: consul-acl-config
            - file: consul-server-service  # if consul.service changes we want to *restart* (reload: False)
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
            - service: consul-server-service-restart
        - require_in:
            - cmd: consul-sync


{% if pillar['consul-cluster']['number-of-nodes'] == 1 %}
consul-singlenode-snapshot-timer:
    file.managed:
        - name: /etc/systemd/system/consul-snapshot.timer
        - source: salt://consul/consul-snapshot.timer


consul-singlenode-snapshot-service:
    file.managed:
        - name: /etc/systemd/system/consul-snapshot.service
        - source: salt://consul/consul-snapshot.service
    service.running:
        - name: consul-snapshot.timer
        - require:
            - file: consul-singlenode-snapshot-timer
            - file: consul-singlenode-snapshot-service
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
        - require_in:  # ensure that all service registrations happen
            - cmd: consul-sync
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
            - service: consul-server-service-reload
        - require_in:
            - cmd: consul-sync


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
