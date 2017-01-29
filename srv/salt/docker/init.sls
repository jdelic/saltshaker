
include:
    - haproxy.docker

docker:
    pkgrepo.managed:
        - humanname: Docker official
        - name: {{pillar["repos"]["docker"]}}
        - file: /etc/apt/sources.list.d/docker.list
        - key_url: salt://docker/docker_0ADBF76221572C52609D.pgp.key
        - require_in:
            - pkg: docker
    pkg.installed:
        - name: docker-engine
        - fromrepo: debian-jessie


# we install a modified docker.service to
#     1. fix the docker0 bridge IP in place
#     2.
dockerd-systemd:
    file.managed:
        - name: /lib/systemd/system/docker.service
        - source: salt://docker/docker.jinja.service
        - template: jinja
        - context:
            bridge_ip: {{pillar['docker']['bridge-ip']}}
            bridge_cidr: {{pillar['docker']['container-cidr']}}
        - require:
            - pkg: docker


dockerd-service:
    service.running:
        - name: docker
        - enable: True
        - require:
            - pkg: docker
            - file: docker-systemd
