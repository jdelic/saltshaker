#!/bin/bash

# concatenate sshd configs

if [ -e /etc/ssh/sshd_config.new ]; then
    rm /etc/ssh/sshd_config.new
fi

for cf in /etc/ssh/sshd_config.d/*; do
    cat $cf >> /etc/ssh/sshd_config.new
done

# test new config
if sshd -f /etc/ssh/sshd_config.new -t; then
    mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config
    systemctl restart sshd
else
    echo "invalid config file detected"
    exit 1
fi

exit 0
