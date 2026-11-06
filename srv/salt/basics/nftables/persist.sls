#
# Persists our nftables rules to /etc/nftables (which /etc/nftables.conf links to, see basics.nftables) so
# nftables.service restores them at boot.
#
# We don't use Salt's "save: True" for this, because it writes out the whole ruleset, including the tables
# and chains created at runtime by Docker, Nomad/CNI and iptables-nft. Restoring those at boot leaves tables
# behind that iptables-nft considers incompatible. This only persists the "saltshaker" tables.
#
# This lives in its own sls, included by basics.nftables.setup, so that states requiring
# "sls: basics.nftables.setup" don't also require this state, which must run last.
#

nftables-persist-script:
    file.managed:
        - name: /usr/local/sbin/nftables-save-saltshaker
        - contents: |
            #!/bin/sh
            # Prints the saltshaker nftables tables (and only those) as an nft script. Loading it replaces
            # the saltshaker tables and leaves all other tables alone. Counters are left out (--stateless)
            # so the output only changes when the rules do.
            set -e
            echo "#!/usr/sbin/nft -f"
            for family in ip ip6; do
                if nft list table $family saltshaker >/dev/null 2>&1; then
                    echo
                    echo "table $family saltshaker"
                    echo "delete table $family saltshaker"
                    nft --stateless list table $family saltshaker
                fi
            done
        - user: root
        - group: root
        - mode: '0755'


nftables-persist:
    cmd.run:
        - name: >
            /usr/local/sbin/nftables-save-saltshaker > /etc/nftables.new &&
            mv /etc/nftables.new /etc/nftables
        - unless: /usr/local/sbin/nftables-save-saltshaker | cmp -s - /etc/nftables
        - order: last
        - require:
            - file: nftables-persist-script


# vim: syntax=yaml
