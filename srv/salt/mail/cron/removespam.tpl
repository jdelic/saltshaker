#!/bin/sh

echo ""
echo "removing spam older than 14 days from all .Spam mailboxes"

if [ ! -d /secure/email ]; then
  echo "/secure/email is down, no action taken"
  exit 1;
fi

REMCOUNT=0

for DIR in `find /secure/email -type d -name .Spam`; do
  NEWCOUNT=`find $DIR/new -mtime 14 -type f | wc -l`
  CURCOUNT=`find $DIR/cur -mtime 14 -type f | wc -l`
  REMCOUNT=$(($REMCOUNT+$NEWCOUNT+$CURCOUNT))

  find $DIR/new -mtime 14 -type f -delete
  find $DIR/cur -mtime 14 -type f -delete
done

echo removed $REMCOUNT spam mails
echo ""
