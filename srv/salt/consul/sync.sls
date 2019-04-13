# require this state to ensure that Consul is properly set up on this node
consul-sync:
    cmd.run:
        - name: /bin/true consul-sync
        - require:
            - cmd: consul-sync-ready


consul-sync-network:
    cmd.run:
        - name: /bin/true consul-sync-network


consul-sync-ready:
    cmd.run:
        - name: /bin/true consul-sync-ready


consul-template-sync:
    cmd.run:
        - name: /bin/true consul-template-sync
