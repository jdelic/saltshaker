

include:
    - haproxy.sync
    - consul.sync
    - docker.install

docker-registry-volume:
    file.directory:
        - name: /srv/registry
        - user: root
        - group: root
        - mode: '0640'

{% set registry_config = pillar.get('docker', {}).get('registry', {}) %}
{% if 'bind-ip' in registry_config %}
{% set registry_ip = registry_config['bind-ip'] %}
{% else %}
{% set registry_ip = grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                     'internal-ip-index', 0)|int()] %}
{% endif %}
{% set registry_port = registry_config.get('bind-port', 5000) %}
{% set registry_hostname = pillar['docker']['registry']['hostname'] %}


docker-registry-envdir:
    file.directory:
        - name: /etc/appconfig/docker-registry/env
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True


docker-registry-envfile:
    file.managed:
        - name: /etc/appconfig/docker-registry/env/envvars
        - user: root
        - group: root
        - mode: '0640'
        - contents: |
            # Managed by Salt
            REGISTRY_AUTH_TOKEN_REALM=https://{{pillar['authserver']['hostname']}}/docker/token/
            REGISTRY_AUTH_TOKEN_SERVICE={{registry_hostname}}
            REGISTRY_AUTH_TOKEN_ISSUER={{pillar['authserver']['hostname']}}
            REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/var/lib/registry/docker_jwt.crt
            REGISTRY_HTTP_HOST=https://{{registry_hostname}}/
            OTEL_TRACES_EXPORTER=none
        - require:
            - file: docker-registry-envdir


docker-jwt-certificate:
    cmd.run:
        - name: >-
            /usr/local/bin/mn-authclient.py -m init --ca-file /etc/ssl/certs/ca-certificates.crt \
                -u https://{{pillar['authserver']['hostname']}}/getkey/ --format cert \
                --domain {{registry_hostname}} --jwtkey /srv/registry/docker_jwt.crt
        - creates: /srv/registry/docker_jwt.crt
        - require:
            - pkg: authclient
            - cmd: smartstack-external-sync
            - cmd: consul-template-sync


docker-registry:
    systemdunit.managed:
        - name: /etc/systemd/system/docker-registry.service
        - source: salt://docker/registry.jinja.service
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
        - context:
            registry_ip: {{registry_ip}}
            registry_port: {{registry_port}}
            registry_hostname: {{registry_hostname}}
    service.running:
        - name: docker-registry
        - enable: True
        - require:
            - file: docker-registry-volume
            - file: docker-registry-envfile
            - cmd: docker-jwt-certificate
            - service: dockerd-service
        - watch:
            - file: docker-registry-envfile
            - cmd: docker-jwt-certificate
            - systemdunit: docker-registry


docker-registry-servicedef:
    file.managed:
        - name: /etc/consul/services.d/docker-registry.json
        - source: salt://docker/consul/docker-registry.jinja.json
        - template: jinja
        - context:
            ip: {{registry_ip}}
            hostname: {{registry_hostname}}
            port: {{registry_port}}
        - require:
            - file: consul-service-dir


docker-registry-tcp-in{{registry_port}}-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{registry_ip}}
        - dport: {{registry_port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


docker-registry-tcp-in{{registry_port}}-forward-ipv4:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - dport: {{registry_port}}
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


# vim: syntax=yaml
