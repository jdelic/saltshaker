# require this state to ensure that PowerDNS is properly set up if the requiring
# state is run on the same server
powerdns-pkg-installed-sync:
    cmd.run:
        - name: /bin/true powerdns-pkg-installed-sync


powerdns-sync:
    cmd.run:
        - name: /bin/true powerdns-sync
