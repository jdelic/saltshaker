# require this state to ensure that haproxy/smartstack is properly set up on this node
smartstack-sync:
    cmd.run:
        - name: /bin/true smartstack-sync
        - require:
            - cmd: smartstack-external-sync
            - cmd: smartstack-internal-sync

# more fine grained states
smartstack-external-sync:
    cmd.run:
        - name: /bin/true smartstack-external-sync


smartstack-internal-sync:
    cmd.run:
        - name: /bin/true smartstack-internal-sync


smartstack-docker-sync:
    cmd.run:
        - name: /bin/true smartstack-docker-sync
