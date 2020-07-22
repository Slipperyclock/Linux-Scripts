#!/bin/bash
# Pull SSH Public Keys from DNS
# Run as regular user.
# Dig must be installed.
# Set the following Variables
# DOMAIN = Base domain for FQDN of host keys. (Inside script)
# HLIST = TXT Record for hosts to enumerate when combined with DOMAIN (Inside script).
#	HLIST="MYHOSTS" will cause txt lookup for MYHOSTS.MYDOMAIN.COM
#	The TXT record should contain hostnames.
#	EX: MYHOSTS.MYDOMAIN.COM TXT = "workstaiton1 workstation2 workstation3"

##### User set these two.
DOMAIN="MYDOMAIN.com"
HLIST="MYHOSTS"
#####################################
#####################################
# Detect Running user
USER=$(whoami)
HOSTS=""
TEMP_AUTHORIZED=/tmp/authorized_keys_$USER.tmp
AUTHORIZED_KEYS=/home/$USER/.ssh/authorized_keys
if [ -e $TEMP_AUTHORIZED ]
then
        rm $TEMP_AUTHORIZED
fi
# Get list of Host Keys
HOSTS=$(dig txt $HLIST.$DOMAIN @8.8.8.8| grep '"'| cut -d '"' -f2)
if [ -z "$HOSTS" ]
then
        echo "Hosts is INVALID or empty."
        exit 0;
fi
for host in $HOSTS
do
        KEY=$(dig txt $host.$DOMAIN| grep '"'| cut -d '"' -f2)
        echo $KEY >> $TEMP_AUTHORIZED
done
AUTH_HASH=$(sha1sum $AUTHORIZED_KEYS| cut -d " " -f1)
TEMP_HASH=$(sha1sum $TEMP_AUTHORIZED| cut -d " " -f1)
if [ "$TEMP_HASH" == "$AUTH_HASH" ]
then
        exit 0;
else
        mv $AUTHORIZED_KEYS $AUTHORIZED_KEYS.o
        cp $TEMP_AUTHORIZED $AUTHORIZED_KEYS
        chmod 644 $AUTHORIZED_KEYS
        chown $USER:$USER $AUTHORIZED_KEYS
fi
