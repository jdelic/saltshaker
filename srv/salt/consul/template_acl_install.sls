{% if not pillar['dynamicsecrets'].get('consul-acl-token', {}).get('firstrun', True) %}
consul-template-acl-config:
    file.managed:
        - name: /etc/consul/consul-template-acl.conf
        - source: salt://consul/consul-template-acl.jinja.conf
        - template: jinja
        - context:
            consul_acl_token: {{pillar['dynamicsecrets']['consul-acl-token']['secret_id']}}
        - require:
            - file: consul-basedir
{% endif %}
