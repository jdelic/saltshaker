
envoy:
    pkgrepo.managed:
        - humanname: Envoy official
        - name: {{pillar["repos"]["envoy"]}}
        - file: /etc/apt/sources.list.d/envoy.list
        - key_url: salt://consul/envoy/envoy_005D0253D0B26FF974DB.pgp.key
    pkg.installed:
        - name: getenvoy-envoy
        - require:
            - pkgrepo: envoy
