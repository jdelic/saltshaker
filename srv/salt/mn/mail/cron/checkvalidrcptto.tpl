#!/bin/bash

#
# [jm, 03/2008]
#
# this script checks if there are any new email accounts
# (as detected by /var/qmail/bin/mkvalidrcptto) and replaces
# the validrcptto cdb as necessary
#

PATH=/bin:/usr/bin:/var/qmail/bin

# don't run if /secure isn't mounted
if [ ! -d /secure/email ]; then exit 0; fi

cd /var/qmail/control

CDBFILE=`tempfile`

# mkvalidrcptto fails if the cdb file exists
rm $CDBFILE

mkvalidrcptto -n -c $CDBFILE

SUM1=`md5sum validrcptto.cdb | cut -d ' ' -f 1`
SUM2=`md5sum $CDBFILE | cut -d ' ' -f 1`

if [ ! "$SUM1" == "$SUM2" ]; then
  echo "new email accounts have been found apparently"
  echo "    old md5: $SUM1"
  echo "    new md5: $SUM2"
  echo ""
  
  TMPFILE1=`tempfile`
  TMPFILE2=`tempfile`
  cdbdump < $CDBFILE > $TMPFILE1
  cdbdump < validrcptto.cdb > $TMPFILE2
  diff -b $TMPFILE2 $TMPFILE1

  rm $TMPFILE1
  rm $TMPFILE2

  echo ""
  echo "replacing validrcptto.cdb"
  mv $CDBFILE validrcptto.cdb
else
  rm $CDBFILE
fi

