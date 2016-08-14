
consul-template:
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["consul-template"]}}
        - source_hash: {{pillar["hashes"]["consul-template"]}}
        - archive_format: zip
        - if_missing: /usr/local/bin/consul-template
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
        - require:
            - file: consul-basedir


consul-template-service:
    file.managed:
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
            - file: consul-template-config
            - file: consul-template-dir
            - file: consul-template
        - watch:
            - file: /etc/consul/template.d*
            - file: /etc/consul/consul-template.conf
            - file: consul-template-service
            - file: consul-template-servicerenderer
            - file: consul-template  # restart on a change of the binary


# https://github.com/hashicorp/consul-template/issues/408
#consul-template-service-reload:
#    service.running:
#        - name: consul-template
#        - sig: consul-template
#        - enable: True
#        - reload: True  # makes Salt send a SIGHUP (systemctl reload consul) instead of restarting
#        - require:
#            - file: consul-template
#            - file: consul-template-config
#            - file: consul-template-dir
#        - watch:
#            - file: /etc/consul/template.d*
#            - file: /etc/consul/consul-template.conf


consul-template-servicerenderer:
    file.managed:
        - name: /etc/consul/servicerenderer.ctmpl.py
        - source: salt://consul/servicerenderer.ctmpl.py
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: consul-basedir


# vim: syntax=yaml
