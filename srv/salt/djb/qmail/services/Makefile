SHELL=/bin/sh

tcp.cdb: tcp
	/usr/bin/tcprules tcp.cdb.new tcp.tmp < tcp
	chmod 644 tcp.cdb.new
	mv tcp.cdb.new tcp.cdb
