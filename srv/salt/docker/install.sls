
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
      - filename: /etc/powerdns/recursor.conf
      - text: {{pillar['docker']['bridge-cidr']}}/24
      - require_in:
          - file: pdns-recursor-config


# enable encryption for overlay nets
docker-overlaynet-enable-protocol50-in:
    nftables.append:
        - table: filter
        - chain: input
        - family: inet
        - jump: accept
        - in-interface: {{pillar['ifassign']['internal']}}
        - proto: 50


docker-overlaynet-enable-protocol50-out:
    nftables.append:
        - table: filter
        - chain: output
        - family: inet
        - jump: accept
        - out-interface: {{pillar['ifassign']['internal']}}
        - proto: 50


docker-overlaynet-udp-in4789-recv:
    nftables.append:
        - table: filter
        - chain: input
        - family: inet
        - jump: accept
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 4789
        - proto: udp
        - save: True
        - require:
            - sls: basics.nftables


docker-overlaynet-udp-in4789-send:
    nftables.append:
        - table: filter
        - chain: output
        - family: inet
        - jump: accept
        - out-interface: {{pillar['ifassign']['internal']}}
        - sport: 4789
        - proto: udp
        - save: True
        - require:
            - sls: basics.nftables


docker-tcp-in7946-recv:
    nftables.append:
        - table: filter
        - chain: input
        - family: inet
        - jump: accept
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 7946
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables


docker-tcp-out7946-send:
    nftables.append:
        - table: filter
        - chain: output
        - family: inet
        - jump: accept
        - out-interface: {{pillar['ifassign']['internal']}}
        - dport: 7946
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables


docker-tcp-in2377-recv:
    nftables.append:
        - table: filter
        - chain: input
        - family: inet
        - jump: accept
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: 2377
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables


docker-tcp-out2377-send:
    nftables.append:
        - table: filter
        - chain: output
        - family: inet
        - jump: accept
        - out-interface: {{pillar['ifassign']['internal']}}
        - dport: 2377
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables
