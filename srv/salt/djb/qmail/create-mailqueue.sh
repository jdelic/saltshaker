#!/bin/sh

echo "creating qmail queue structure in $1"

if [ ! -e "$1" ]; then
    echo "$1 does not exist. Exiting"
    exit 1;
fi

cd "$1"
mkdir mess
for i in $(seq 0 22); do
    mkdir -p mess/$i
done

for d in info local remote; do
    cp -r mess $d
done

mkdir todo
mkdir intd
mkdir bounce
mkdir pid
mkdir lock
touch lock/sendmutex
chmod -R 750 mess todo lock
chown -R qmailq.qmail mess todo lock

chmod -R 700 info intd local remote bounce pid
chown -R qmailq.qmail intd pid
chown -R qmails.qmail info local remote bounce lock/sendmutex

echo "done."

