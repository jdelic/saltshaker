
include:
    - consul.template_acl_install
    - consul.sync


consul-template:
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["consul-template"]}}
        - source_hash: {{pillar["hashes"]["consul-template"]}}
        - keep: True
        - archive_format: zip
        - unless: test -f /usr/local/bin/consul-template  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/bin/consul-template
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/consul-template
        - mode: '0750'
        - user: root
        - group: root
        - replace: False
        - require:
            - archive: consul-template


consul-template-dir:
    file.directory:
        - name: /etc/consul/template.d
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - file: consul-basedir


consul-renders-dir:
    file.directory:
        - name: /etc/consul/renders
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - file: consul-basedir


consul-template-config:
    file.managed:
        - name: /etc/consul/consul-template.conf
        - source: salt://consul/consul-template.jinja.conf
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
        - context:
            cacert: {{pillar['ssl']['service-rootca-cert']
                        if pillar['vault'].get('pinned-ca-cert', 'default') == 'default'
                        else pillar['vault']['pinned-ca-cert']}}
            vault_url: https://{{pillar['vault']['smartstack-hostname']}}:8200/
        - require:
            - file: consul-basedir


{% if pillar['dynamicsecrets']['consul-acl-token']['firstrun'] %}
# work around the insane hoops we have to jump through for
# https://github.com/hashicorp/consul/issues/4977
consul-template-firstrun-config:
    cmd.run:
        - name: >
            sed "s#^\(\s*\)token =.*#\1token = \"$(jq -r .acl.tokens.agent /etc/consul/conf.d/agent_acl.json)\"#" \
                /etc/consul/consul-template-acl.conf > /etc/consul/consul-template-acl.conf.new;
            mv /etc/consul/consul-template-acl.conf.new /etc/consul/consul-template-acl.conf
        - onlyif: grep -q "first run" /etc/consul/consul-template-acl.conf
        - require:
            - file: consul-template-config
        - require_in:
            - service: consul-template-service
        - watch_in:
            - service: consul-template-service-reload
{% endif %}


consul-template-service:
    systemdunit.managed:
        - name: /etc/systemd/system/consul-template.service
        - source: salt://consul/consul-template.jinja.service
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
    service.running:
        - name: consul-template
        - sig: consul-template
        - enable: True
        - require:
            - file: consul-run-dir
            - file: consul-template-config
            - file: consul-template-acl-config
            - file: consul-template-dir
            - file: consul-template-servicerenderer
            - cmd: consul-sync
        - watch:
            - systemdunit: consul-template-service
            - file: consul-template  # restart on a change of the binary
        - require_in:
            - cmd: consul-template-sync


consul-template-service-reload:
    service.running:
        - name: consul-template
        - sig: consul-template
        - enable: True
        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
        - require:
            - file: consul-template
            - file: consul-template-config
            - file: consul-template-dir
        - watch:
            # this does NOT have to watch consul-template-acl-config as the reload is done via the
            # orchestrator in consul-node-setup
            - file: /etc/consul/template.d*
            - file: /etc/consul/consul-template.conf
            - cmd: consul-template-servicerenderer
        - require_in:
            - cmd: consul-template-sync


consul-template-servicerenderer:
    file.managed:
        - name: /etc/consul/servicerenderer.ctmpl.py
        - source: salt://consul/servicerenderer.ctmpl.py
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: consul-basedir
    cmd.run:
        - name: >
            test ! -z "$(ls -A /etc/consul/renders)" && rm /etc/consul/renders/*; /bin/true
        - onchanges:
            - file: consul-template-servicerenderer
        - require:
            - file: consul-renders-dir


consul-template-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/49-consul-template.rsyslog.conf
        - source: salt://consul/49-consul-template.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'

# vim: syntax=yaml
