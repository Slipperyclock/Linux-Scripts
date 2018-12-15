#!/bin/bash
#Script to automate mounting cloud volume with Rclone and backup with Duplicacy.
#Slipperyclock 12/2018

LAST=0
MOUNTED=0
TAG=$HOSTNAME-$(date +%Y-%m-%d-%H%M)
STORAGE=(OPTIONAL)RCLONE_STORAGENAME
REPOSITORY=/MY/BACKUP/SOURCE
REMOTE_PATH=/MY/BACKUP/DESTINATION
RCLONE_REMOTE=REMOTELOCATION:/BACKUP/DESTINATION/FOR/RCLONE/TO/MOUNT
LOG=/var/log/duplicacy/$HOSTNAME_.log
DAY=$(date +%d)

is_mounted () {
        df | grep -q $REMOTE_PATH; LAST=$?
        if [ $LAST = 0 ]
        then
	        # Set Mounted to true
                MOUNTED=0;
        elif [ $LAST = 1 ]
        then
                # Set Mounted to false
                MOUNTED=1
        else
            	echo "IDK what to tell you but it failed: $LAST"
        fi
}
is_mounted

if [ $MOUNTED = 1 ] 
then
    	echo "Destination not mounted, mounting now."
        echo "With Command:rclone mount $RCLONE_REMOTE $REMOTE_PATH";
        rclone mount $RCLONE_REMOTE $REMOTE_PATH&
        sleep 3

        is_mounted
fi

if [ $MOUNTED = 0 ]
then
	sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "$STORAGE $HOSTNAME" "Start @$(date)"
	cd $REPOSITORY
	echo "[*] [*] [*] [*] [*] Begin Backup of $REPOSITORY $(date) [*] [*] [*] [*] [*]" >> $LOG
	echo "[*]">> $LOG
	echo "[*] Listing Repository">> $LOG
	duplicacy list >> $LOG
	echo "[*] ">> $LOG
	echo "[*] Begin duplicacy backup of $REPOSITORY to $STORAGE">> $LOG
	# every 14 days do a hash job
	if [ $DAY -eq 14 ] || [ $DAY -eq 28 ] 
	then
	    	echo "[*] It's Hash day" >> $LOG
	        duplicacy backup -t $TAG -threads 1 -storage $STORAGE -stats -hash >> $LOG
	else
	    	duplicacy backup -t $TAG -threads 1 -storage $STORAGE -stats >> $LOG
	fi
	echo "[*] Complete">> $LOG
	echo "[*]">> $LOG
	echo "[*] Initiate Prune">> $LOG
	duplicacy prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7 >> $LOG
	echo "[*] Complete">> $LOG
	echo "[*]" >> $LOG
	echo "[*] List Repository" >> $LOG
	duplicacy list >> $LOG
	fusermount -uz $REMOTE_PATH
	echo "[*] [*] [*] [*] [*] DONE $(date) [*] [*] [*] [*] [*]" >> $LOG
	echo "" >> $LOG
	echo "" >> $LOG
	sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "$STORAGE $HOSTNAME" "End $REPOSITORY @$(date)"
else
	echo "[*] "
	echo "[*] "
	echo "[*] MOUNT FAILED NO BACKUP"
fi
