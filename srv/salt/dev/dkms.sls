# This file has dependencies needed to rebuilding virtualbox dependencies during box updates.
# Without this, rebooting vagrant boxes might fail after a kernel update.

linux-headers-amd64:
    pkg.installed
