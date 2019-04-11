# on first run this will not render a real consul ACL. This is taken care of in
# consul.template.consul-template-firstrun-config
consul-template-acl-config:
    file.managed:
        - name: /etc/consul/consul-template-acl.conf
        - source: salt://consul/consul-template-acl.jinja.conf
        - template: jinja
        - context:
            consul_acl_token: {{pillar['dynamicsecrets']['consul-acl-token']['secret_id']}}
        - require:
            - file: consul-basedir
{% if not pillar['dynamicsecrets'].get('consul-acl-token', {}).get('firstrun', True) %}
    cmd.run:
        - name: >
            until test ${count} -gt 30; do
                if test $(curl -s -H "X-Consul-Token: $CONSUL_TEMPLATE_TOKEN" \
                            http://169.254.1.1:8500/v1/acl/token/self | jq '.Policies|length') -gt 0; then
                    break;
                fi
                sleep 1; count=$((count+1));
            done; test ${count} -lt 30
        - env:
            count: 0
            CONSUL_TEMPLATE_TOKEN: {{pillar['dynamicsecrets']['consul-acl-token']['secret_id']}}
        - onchanges:
            - file: consul-template-acl-config
        - require:
            - cmd: consul-sync
{% endif %}
