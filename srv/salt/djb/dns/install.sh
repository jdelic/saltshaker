#!/bin/sh
# This script patches, compiles and installs djbdns

if [ ! -e djbdns-1.05 ]; then
    tar xfz djbdns-1.05.tar.gz
fi
cd djbdns-1.05

# check whether the source tree is already patched
if ! grep -q errno.h conf-cc; then
    sed 's/gcc/gcc -include errno.h/g' conf-cc > conf-cc.new
    mv conf-cc.new conf-cc
    sed 's/local/local\/djbdns-1.05/g' conf-home > conf-home.new
    mv conf-home.new conf-home
fi

# compile and install to /usr/local/djbdns-1.05
make
make setup check

