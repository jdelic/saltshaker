# require this state to ensure that PowerDNS is properly set up if the requiring
# state is run on the same server
powerdns-sync:
    cmd.run:
        - name: /bin/true powerdns-sync
