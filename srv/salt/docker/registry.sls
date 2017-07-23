
docker-registry-volume:
    file.directory:
        - name: /srv/registry
        - user: root
        - group: root
        - mode: '0640'

{% set registry_ip = pillar.get('docker', {}).get('registry', {}).get(
                         'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                         'internal-ip-index', 0)|int()]
                     ) %}
{% set registry_port = pillar.get('docker', {}).get('registry', {}).get('bind-port', 5000) %}
{% set registry_hostname = pillar['docker']['registry']['hostname'] %}


docker-jwt-certificate:
    cmd.run:
        - name: >-
            JWTFILE=$(mktemp) &&
            echo "$JWT_KEY" > "$JWTFILE" &&
            /usr/bin/openssl req -x509 -key $JWTFILE -out /srv/registry/docker_jwt.crt \
                -days 3650 \
                -subj '/C=DE/L=Munich/O=Docker Registry/OU=JWT Auth/CN={{pillar['authserver']['hostname']}}/';
            rm $JWTFILE;
        - creates: /srv/registry/docker_jwt.crt
        - env:
            JWT_KEY: |
                {{pillar['dynamicsecrets']['dockerauth-jwt-key']['key']|indent(16)}}


docker-registry:
    docker_container.running:
        - name: registry
        - image: registry:latest
        - binds:
            - /srv/registry:/var/lib/registry
            - {{pillar['ssl']['service-rootca-cert']}}:{{pillar['ssl']['service-rootca-cert']}}
            - {{pillar['ssl']['filenames']['default-cert']}}:{{pillar['ssl']['filenames']['default-cert']}}
            - {{pillar['ssl']['filenames']['default-cert-key']}}:{{pillar['ssl']['filenames']['default-cert-key']}}
        - port_bindings:
            - {{registry_ip}}:{{registry_port}}:5000
        - dns:
            - 169.254.1.1
        - restart_policy: always
        - environment:
            - REGISTRY_AUTH_TOKEN_REALM: >
                {{pillar['authserver']['protocol']}}://{{pillar['authserver']['hostname']}}/docker/token/
            - REGISTRY_AUTH_TOKEN_SERVICE: {{registry_hostname}}
            - REGISTRY_AUTH_TOKEN_ISSUER: {{pillar['authserver']['hostname']}}
            - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE: /var/lib/registry/docker_jwt.crt
            - REGISTRY_HTTP_HOST: https://{{registry_hostname}}/
        - extra_hosts: {{registry_hostname}}:{{registry_ip}}
        - require:
            - file: docker-registry-volume
            - cmd: docker-jwt-certificate


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
            - dockerng: docker-registry
            - file: consul-service-dir


docker-registry-tcp-in{{pillar.get('docker', {}).get('registry', {}).get('bind-port', 5000)}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{registry_ip}}
        - dport: {{registry_port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
