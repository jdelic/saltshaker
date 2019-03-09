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
