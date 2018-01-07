#!/bin/bash
# syntax: ./set-zfs-userquota.sh <DIR> <LIMIT> <DATASET>
# DIR:          directory where all homes are located
# LIMIT:        quota limit
# DATASET:      dataset to apply quota
# sample call: ./set-zfs-userquota.sh /mnt/students/homes 500M students/homes

for f in $1/*; do
    if [ -d $f ]; then
        echo processing $(basename $f)
        zfs set userquota@$(basename $f)=$2 $3
    fi
done
