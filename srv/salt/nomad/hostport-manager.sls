# This state makes sure that containers that need to call out to certain port ranges or use
# host networking can be reached by the loadbalancers.

{% set internal_ip = pillar.get('nomad', {}).get('override-ipv4',
        grains['ip4_interfaces'].get(pillar['ifassign']['internal'], {})[pillar['ifassign'].get('internal-ip-index', 0)|int()]) %}

hostport-manager-runner:
    file.managed:
        - name: /etc/consul/helpers/hostport-manager-runner.sh
        - contents: |
            #!/bin/bash
            set -e
            /usr/bin/python3 /etc/consul/renders/smartstack-hostport-manager.py \
                --only-nftables \
                --include 'tags=smartstack:external,tags=regex=smartstack:hostport:(.*)' \
                --open-nftables=conntrack \
                --nftables-rules=input \
                --smartstack-localip {{internal_ip}}
        - mode: 750
        - require:
            - file: consul-helpers-dir


smartstack-hostport-manager:
    file.managed:
        - name: /etc/consul/template.d/smartstack-hostport-manager.conf
        - source: salt://consul/template-config.jinja.conf
        - template: jinja
        - context:
            servicescript: /etc/consul/renders/smartstack-hostport-manager.py
            command: /etc/consul/helpers/hostport-manager-runner.sh
        - require:
            - file: consul-template-dir
            - file: hostport-manager-runner
