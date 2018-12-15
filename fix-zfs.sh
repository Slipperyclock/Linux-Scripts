#!/bin/bash
#Lame 5 liner to rebuild the zfs/spl kernel modules for fedora when kernel is updated.  
#Need to automate version number for eaiser use.
#Slipperyclock 12/2018
dkms install -m spl/0.7.12 -k $(uname -r)
dkms install -m zfs/0.7.12 -k $(uname -r)
modprobe zfs
zpool import
zpool import pool
