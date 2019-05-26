
# This state configures consul as a cluster SERVER. It's mutually exclusive with the consul.agent state.
# You can find more details in consul.install

include:
    - consul.install
    - consul.sync
    - consul.acl_install  # during firstrun, this state is empty


{% from 'consul/install.sls' import consul_user, consul_group %}

{% set single_node_cluster = pillar['consul-cluster']['number-of-nodes'] == 1 %}

consul-acl-bootstrap-config:
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


consul-acl-token-envvar:
    file.managed:
        - name: /etc/consul/operator_token_envvar
        - contents: |
            CONSUL_HTTP_TOKEN="{{pillar['dynamicsecrets']['consul-acl-master-token']}}"
        - user: root
        - group: root
        - mode: '0640'
        - require:
            - file: consul-basedir


consul-agent-token-envvar:
    file.managed:
        - name: /etc/consul/agentmaster_token_envvar
        - contents: |
            CONSUL_HTTP_TOKEN="{{pillar['dynamicsecrets']['consul-agent-master-token']}}"
        - user: root
        - group: root
        - mode: '0640'
        - require:
            - file: consul-basedir


consul-service:
    systemdunit.managed:
        - name: /etc/systemd/system/consul-server.service
        - source: salt://consul/consul.jinja.service
        - template: jinja
        - context:
            user: {{consul_user}}
            group: {{consul_group}}
            extra_parameters: -server -bootstrap-expect={{pillar['consul-cluster']['number-of-nodes']}} -ui
            single_node_cluster: {% if single_node_cluster %}True{% else %}False{% endif %}
            node_name: {{grains['id']}}
    {% if single_node_cluster %}
            node_id: {{pillar['dynamicsecrets']['consul-node-id']}}
    {% endif %}
        - require:
            - file: consul
            - file: consul-agent-absent
            # this is here so that the WantedBy in our systemd service definition is processed correctly
            - pkg: pdns-recursor
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
            - file: consul-acl-bootstrap-config
            - systemdunit: consul-service
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                if test $(curl -s -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" \
                            http://169.254.1.1:8500/v1/agent/members | jq 'length') -gt 0; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - require:
            - service: consul-service
        - require_in:
            - cmd: consul-sync-ready


{% if pillar['dynamicsecrets']['consul-acl-token']['firstrun'] %}
# on the master server, to fix the chicken egg problem of the ACL initialization, we install the server
# and run it, then install a temporary ACL config and restart the server.
# If we're not in firstrun, the inclusion of consul.acl_install at the top of this file will take care
# of the ACL configuration.
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
            - cmd: consul-service


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
            - service: consul-service-restart
{% endif %}


consul-service-restart:
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - init_delay: 2
        - watch:
            - file: consul-acl-bootstrap-config
            - file: consul-common-config
            - file: consul  # restart on a change of the binary
            - systemdunit: consul-service  # if consul.service changes we want to *restart* (reload: False)
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                if test $(curl -s -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" \
                            http://169.254.1.1:8500/v1/agent/members | jq 'length') -gt 0; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - onchanges:
            - service: consul-service-restart
        - require_in:
            - cmd: consul-sync-ready


{% if pillar['consul-cluster']['number-of-nodes'] == 1 %}
consul-singlenode-snapshot-timer:
    file.managed:
        - name: /etc/systemd/system/consul-snapshot.timer
        - source: salt://consul/consul-snapshot.timer


consul-singlenode-snapshot-service:
    systemdunit.managed:
        - name: /etc/systemd/system/consul-snapshot.service
        - source: salt://consul/consul-snapshot.service
    service.running:
        - name: consul-snapshot.timer
        - require:
            - file: consul-singlenode-snapshot-timer
            - systemdunit: consul-singlenode-snapshot-service
            - service: consul-service
{% endif %}


consul-service-reload:
    service.running:
        - name: consul-server
        - sig: consul
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - init_delay: 1
        - require:
            - systemdunit: consul-service  # if consul.service changes we want to *restart* (reload: False)
        - watch:
            # If we detect a change in the service definitions reload, don't restart. This matches STATE names not FILE
            # names, so this watch ONLY works on STATES named /etc/consul/services.d/[whatever]!
            # We match on services.d with NO TRAILING SLASH because otherwise the watch prerequisite will FAIL if there
            # is no other state that matches "/etc/consul/services.d/*" whereas "/etc/consul/services.d*" will match the
            # consul.install.consul-service-dir state.
            - file: /etc/consul/services.d*
{% if not pillar['dynamicsecrets']['consul-acl-token']['firstrun'] %}
            - file: consul-acl-agent-config
{% endif %}
        - require_in:  # ensure that all service registrations happen
            - cmd: consul-sync
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                if test $(curl -s -H "X-Consul-Token: $CONSUL_ACL_MASTER_TOKEN" \
                            http://169.254.1.1:8500/v1/agent/members | jq 'length') -gt 0; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
            CONSUL_ACL_MASTER_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - onchanges:
            - service: consul-service-reload
        - require_in:
            - cmd: consul-sync-ready


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
