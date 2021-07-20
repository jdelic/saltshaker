
envoy:
    pkgrepo.managed:
        - humanname: Envoy official
        - name: {{pillar["repos"]["envoy"]}}
        - file: /etc/apt/sources.list.d/envoy.list
        - key_url: salt://consul/envoy/envoy_8115BA8E629CC074.pgp.key
    pkg.installed:
        - name: getenvoy-envoy
        - require:
            - pkgrepo: envoy
