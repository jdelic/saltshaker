# This state makes sure that containers that need to call out to certain port ranges or use
# host networking can be reached by the loadbalancers.

{% set internal_ip = pillar.get('nomad', {}).get('override-ipv4',
        grains['ip4_interfaces'].get(pillar['ifassign']['internal'], {})[pillar['ifassign'].get('internal-ip-index', 0)|int()]) %}

smartstack-hostport-manager:
    file.managed:
        - name: /etc/consul/template.d/smartstack-hostport-manager.conf
        - source: salt://nomad/consul-template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-hostport-manager.py
            parameters: >
                --only-nftables
                --include 'tags=smartstack:external,tags=regex=smartstack:hostport:(.*)'
                --include 'tags=smartstack:external,tags=regex=smartstack:outport:(.*)'
                --open-nftables=conntrack
                --smartstack-localip {{internal_ip}}
        - require:
            - file: consul-template-dir
