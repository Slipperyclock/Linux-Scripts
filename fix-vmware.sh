#!/bin/bash
#Fix Vmware Workstation in Fedora when kernel is updated
#Slipperyclock 12/2018

dnf install elfutils-libelf-devel
cp /usr/include/linux/version.h /lib/modules/$(uname -r)/build/include/linux/
vmware-modconfig --console --install-all
