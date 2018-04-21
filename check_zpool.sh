#!/bin/sh
# Check zpool status
# Use this for Nagios monitoring

status=$( /sbin/zpool status -x )

if [ "${status}" == "all pools are healthy" ]; then
        echo "ALL ZPOOLS OK"
else
        echo "SOME ZPOOLS CRITICAL"
fi

/sbin/zpool status
