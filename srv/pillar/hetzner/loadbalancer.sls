haproxy:
    bind-ipv4: True
    bind-ipv6: False
    override-ipv4: {{grains['ip4_interfaces'].get(pillar['ifassign']['internal'], {}).get(pillar['ifassign'].get('internal-ip-index', 0)|int()) }}