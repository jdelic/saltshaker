# This state makes sure that containers that need to call out to certain port ranges or use
# host networking can be reached by the loadbalancers.

{% set external_ip = pillar.get('nomad', {}).get('override-outport-ipv4',
        grains['ip4_interfaces'].get(pillar['ifassign']['external'], {})[pillar['ifassign'].get('external-ip-index', 0)|int()]) %}
{% set external_ipv6 = pillar.get('nomad', {}).get('override-outport-ipv6',
        salt['network.calc_net'](salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")[0] + "/64").removesuffix("/64") +
            pillar['ifassign-ipv6'].get('external-ipv6-suffix', "1")
                if salt['network.ip_addrs6'](pillar['ifassign-ipv6']['external'], False, "2000::/4")|length > 0 else ""
    ) %}
outport-manager-runner:
    file.managed:
        - name: /etc/consul/helpers/outport-manager-runner.sh
        - contents: |
            #!/bin/bash
            set -e
            /usr/bin/python3 /etc/consul/renders/smartstack-outport-manager.py \
                --only-nftables \
                --include 'tags=smartstack:external,tags=regex=smartstack:outport:(.*)' \
                --open-nftables=conntrack \
                --nftables-rules=input \
                --smartstack-localip {{external_ip}}
                --smartstack-localip {{external_ipv6}}
        - mode: 750
        - require:
            - file: consul-helpers-dir


smartstack-outport-manager:
    file.managed:
        - name: /etc/consul/template.d/smartstack-outport-manager.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-outport-manager.py
            command: /etc/consul/helpers/outport-manager-runner.sh
        - require:
            - file: consul-template-dir
            - file: outport-manager-runner
