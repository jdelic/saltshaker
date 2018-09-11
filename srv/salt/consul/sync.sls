# require this state to ensure that Consul is properly set up on this node
consul-sync:
    cmd.run:
        - name: /bin/true
