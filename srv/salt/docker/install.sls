
include:
    - haproxy.docker

docker:
    pkgrepo.managed:
        - humanname: Docker official
        - name: {{pillar["repos"]["docker"]}}
        - file: /etc/apt/sources.list.d/docker.list
        - key_url: salt://docker/docker_8D81803C0EBFCD88.pgp.key
        - aptkey: False
        - require_in:
            - pkg: docker
    pkg.installed:
        - pkgs:
            - docker-ce
            - docker-ce-cli
            - containerd.io


# we install a modified docker.service to
#     1. fix the docker0 bridge IP in place
#     2.
dockerd-systemd:
    systemdunit.managed:
        - name: /lib/systemd/system/docker.service
        - source: salt://docker/docker.jinja.service
        - template: jinja
        - context:
            bridge_cidr: {{pillar['docker']['bridge-cidr']}}
            container_cidr: {{pillar['docker']['container-cidr']}}
        - require:
            - pkg: docker


dockerd-service:
    service.running:
        - name: docker
        - enable: True
        - require:
            - pkg: docker
        - watch:
            - systemdunit: dockerd-systemd


# TODO: add a DROP rule to the FORWARD chain so not every container gets hooked up
# to the internet


docker-pdns-recursor-cidr:
  file.accumulated:
      - name: powerdns-recursor-additional-cidrs
      - filename: /etc/powerdns/recursor.d/saltshaker.yml
      - text: {{pillar['docker']['bridge-cidr']}}
      - require_in:
          - file: pdns-recursor-config


# vim: syntax=yaml
