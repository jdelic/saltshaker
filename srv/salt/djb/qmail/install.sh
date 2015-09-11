#!/bin/sh
# This script patches, compiles and installs qmail with John Simpson's
# patch

if [ ! -e qmail-1.03 ]; then
    tar xfz qmail-1.03.tar.gz
fi
cd qmail-1.03

# check whether the source tree is already patched
if ! echo "fbf38291a403d0f6c93cf639fe09cf2f  qmail.c" | md5sum -c --status; then
    patch < ../qmail-1.03-jms1-7.10.patch
fi

# compile and install to /var/qmail
make
make setup check

./config-fast $1

