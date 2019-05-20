#
# This state is run on two occasions. The first is: consul.agent and consul.server both include it
# during a highstate after the ACL system is initialized on the salt-master (after the "firstrun").
# The second is: When a minion boots
#     - it sends a Salt event through the Salt event bus (salt/minion/<mid>/start)
#     - which triggers a Salt reactor on the salt-master,
#     - which runs a salt.orchestrate state which creates new
#     - ACL tokens on the salt-master's consul server and then in turn
#     - triggers this state, thereby installing the new ACL tokens in the local consul
#
# For this to work, the states in this file are formulated so that they work both on agents and servers alike.
#

{% if not pillar['dynamicsecrets'].get('consul-acl-token', {}).get('firstrun', True) %}

include:
    - consul.sync
    - iptables  # this is a necessary dependency, absolving us from passing dependencies in targeted state.sls runs
{% if pillar['dynamicsecrets'].get('consul-acl-master-token', False) %}
    {# I didn't come up with a better idea to detect whether this runs on a consul.server or agent #}
    - consul.server
{% else %}
    - consul.agent
{% endif %}

{% from 'consul/install.sls' import consul_user, consul_group %}


# when we have a server, we run it, then
consul-register-acl:
    # notify the salt master to configure the unconfigured ACL token created by dynamicsecrets when the minion
    # pillars were filled
    event.send:
        - name: maurusnet/consul/installed
        - require:
            - cmd: consul-sync-ready
            - file: consul-acl-agent-config
    # this state then waits for the master orchestrator to do its job and attach the right policies to
    # the unconfigured token. To do so we need consul to run already.
    http.wait_for_successful_query:
        - name: http://169.254.1.1:8500/v1/acl/info/{{pillar['dynamicsecrets']['consul-acl-token']['accessor_id']}}
        - wait_for: 10
        - request_interval: 1
        - raise_error: False  # only exists in 'tornado' backend
        - backend: tornado
        - status: 200
        - require:
            - event: consul-register-acl
            - service: consul-service
        - require_in:
            - cmd: consul-sync


consul-acl-agent-config:
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
            - file: consul-conf-dir
            - user: consul
            - group: consul
{% endif %}  # firstrun check

{% if pillar['dynamicsecrets'].get('consul-acl-master-token', False) %}
# these states only execute on consul servers and ensure correct config for the well-known tokens
consul-update-anonymous-policy:
    cmd.run:
        - name: >
            curl -i -s -X PUT -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
                --data @/etc/consul/policies.d/anonymous.json \
                http://169.254.1.1:8500/v1/acl/policy
        - env:
            CONSUL_HTTP_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - unless: /usr/local/bin/consul acl policy list | grep "^anonymous" >/dev/null
        - require:
            - file: consul-policy-anonymous
            - cmd: consul-sync-ready
        - watch:
            - service: consul-service


consul-update-anonymous-token:
    cmd.run:
        - name: >
            curl -i -s -X PUT -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
                --data '{ "SecretID": "anonymous", "Policies": [{ "Name": "anonymous" }] }' \
                http://169.254.1.1:8500/v1/acl/token/00000000-0000-0000-0000-000000000002
        - env:
            CONSUL_HTTP_TOKEN: {{pillar['dynamicsecrets']['consul-acl-master-token']}}
        - require:
            - cmd: consul-update-anonymous-policy
        - watch:
            - service: consul-service
{% endif %}
