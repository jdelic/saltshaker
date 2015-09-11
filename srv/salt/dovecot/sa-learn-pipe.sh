#!/bin/bash

# see http://wiki2.dovecot.org/Plugins/Antispam

TEMPFILE=$(mktemp)
cat<&0 >>$TEMPFILE
/usr/bin/sa-learn $* $TEMPFILE
rm -f $TEMPFILE

exit 0

