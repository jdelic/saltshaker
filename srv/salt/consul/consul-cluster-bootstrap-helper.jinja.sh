#!/bin/bash

# Exit if /etc/salt/roles.d/consulbootstrapprimary does not exist
if [ ! -f /etc/salt/roles.d/consulbootstrapprimary ]; then
    exit 0
fi

# Check the number of registered Consul servers using curl and jq
CONSUL_SERVERS=$(curl -s http://127.0.0.1:8500/v1/agent/members | jq '[.[] | select(.Tags.role == "consul" and .Status == 1)] | length')

# If there are N servers in the cluster, proceed with the next steps
if [[ "$CONSUL_SERVERS" -ge {{target_number}} ]]; then
    # Modify the consul-server systemd unit to remove '-bootstrap'
    if grep -q "\-bootstrap" /etc/systemd/system/consul-server.service; then
        sed -i 's/ -bootstrap//g' /etc/systemd/system/consul-server.service

        # Reload systemd to apply the changes to the unit file
        systemctl daemon-reload

        # Remove the file that marks this node as a bootstrap node
        if [ -f /etc/salt/roles.d/consulbootstrapprimary ]; then
            rm /etc/salt/roles.d/consulbootstrapprimary
            salt-call saltutil.sync_grains
        fi

        # Restart the Consul service
        systemctl restart consul-server.service

        # Disable the timer and service as they are no longer needed
        systemctl stop consul-check.timer
        systemctl disable consul-check.timer
        systemctl disable consul-check.service
        systemctl daemon-reload
    fi
fi
