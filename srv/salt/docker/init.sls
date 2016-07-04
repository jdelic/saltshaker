
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
    service.running:
        - name: docker
        - enable: True
        - require:
            - pkg: jenkins
