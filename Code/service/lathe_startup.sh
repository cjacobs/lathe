#!/bin/sh

### BEGIN INIT INFO
# Provides:          lathe
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
### END INIT INFO

set -x

echo "Starting lathe service..."

cd ~/lathe/Code

python lathe.py knobs &

echo "  ..done"

exit 0
