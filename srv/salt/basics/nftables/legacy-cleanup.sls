#
# One-time migration: Salt used to keep its chains in the "filter" and "nat" tables, which it shared with
# iptables-nft. Now our rules live in the "saltshaker" tables, so this removes our old chains from the
# shared tables. iptables-nft only uses uppercase chain names (INPUT, FORWARD, DOCKER, CNI-..., NOMAD-ADMIN),
# so this never touches its chains.
#
# The old chains aren't persisted anymore, so a reboot removes them as well. Apply this manually after a
# highstate has set up the saltshaker tables and consul-template has re-rendered the smartstack rules:
#
#     salt 'host' state.apply basics.nftables.legacy-cleanup
#

{% set legacy_chains = [
    "ip filter input", "ip filter output", "ip filter forward",
    "ip6 filter input", "ip6 filter output", "ip6 filter forward",
    "ip nat prerouting", "ip nat postrouting",
] %}
nftables-remove-legacy-chains:
    cmd.run:
        - name: >
            set -e;
            {%- for chain in legacy_chains %}
            if nft list chain {{chain}} >/dev/null 2>&1; then
                nft flush chain {{chain}}; nft delete chain {{chain}};
            fi;
            {%- endfor %}
        - onlyif: >
            {%- for chain in legacy_chains %}
            nft list chain {{chain}} >/dev/null 2>&1 ||
            {%- endfor %}
            /bin/false


# vim: syntax=yaml
