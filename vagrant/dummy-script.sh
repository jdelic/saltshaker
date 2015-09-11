#!/bin/sh

echo "running bootstrap dummy for salt..."
echo "Command: $@"
LAST_PARAM=""
while echo "$1" | grep -q -E '^-'; do
    if [ "$1" = "$LAST_PARAM" ]; then
        echo "unknown parameter: $LAST_PARAM"
        shift
    fi
    LAST_PARAM="$1"
    if [ "$1" = "-minion" ]; then
        shift
        MINION_ID="$1"
        echo "Setting minion_id to $MINION_ID"
        echo $MINION_ID > /etc/salt/minion_id
        shift
    fi
done

if [ -e /tmp/minion.pem ]; then
    mkdir -p /etc/salt/pki/minion
    mv /tmp/minion /etc/salt/minion
    mv /tmp/minion.p* /etc/salt/pki/minion/
fi

systemctl restart salt-minion
exit 0;
