
docker-registry-volume:
    file.directory:
        - name: /srv/registry
        - user: root
        - group: root
        - mode: '0640'


docker-registry:
    dockerng.running:
        - name: registry
        - image: registry:latest
        - binds:
            - /srv/registry:/var/lib/registry
        - port_bindings:
            - {{pillar.get('docker-registry', {}).get(
                    'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0)|int()]
              )}}:5000:5000
        - dns:
            - 169.254.1.1
        - restart_policy: on-failure:5
        - require:
            - file: docker-registry-volume


# vim: syntax=yaml
