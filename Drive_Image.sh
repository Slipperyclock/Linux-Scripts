#!/bin/bash
#       Slipperyclock 12/2018
#       Script DD a physical disk, compresses then encrypt.
#

# Where to send images
LOC=/Backups/DD/ 
# Source drive to take image of
DRIVE=/dev/nvme0n1
# Send log output to location
LOGFILE=/var/log/image_backup.log
# Optional Password for encryption
PASSWD=MYSUPERSECRETPASSWORD
#Parameters for image naming
KERNEL=$(uname -r| cut -d"." -f1-3)
IMAGE_NAME=$HOSTNAME_$KERNEL-$(date +%Y_%m_%d_%H%M)
# Encryption
## openssl aes-256-cbc -salt -e -k PASSWORD
# Compression
## gzip -9 -c 

echo "------------------------------------------------------------------------ ">>$LOGFILE;
echo "[*] Start Image Backup Script $(date)">>$LOGFILE;
echo "[*] Image: $LOC$IMAGE_NAME.img.gz">>$LOGFILE;
echo "[*] Begining image generation">>$LOGFILE;
#If drive already encrypted leave commented out
# time dd if=$DRIVE conv=sync,noerror |gzip -9 -c | openssl aes-256-cbc -salt -e -k $PASSWD > $LOC$IMAGE_NAME.img.gz
time dd if=$DRIVE conv=sync,noerror of=$LOC$IMAGE_NAME.img
echo "[*]" >>$LOGFILE;
sudo -u $(who -u| cut -d " " -f1) DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "Local Backup" "Backup complete, starting hash. @$(date)"
echo "[*] ----Image Details----">>$LOGFILE;
echo "[*] Image Date:           $(date +%Y-%m-%d" "%T)">>$LOGFILE;
echo "[*] Image Name:           $IMAGE_NAME">>$LOGFILE;
echo "[*] Image Kernel:           $KERNEL">>$LOGFILE;
echo "[*] Image Drive:          $DRIVE">>$LOGFILE;
echo "[*] Image Size:           $(du -sch $LOC$IMAGE_NAME.img | cut -d$'\t' -f1 | head -n1).">>$LOGFILE;
echo "[*] Image SHA256:         $(sha256sum $LOC$IMAGE_NAME.img)">>$LOGFILE;
echo "[*]">>$LOGFILE;
echo "[*]">>$LOGFILE;

#Keep most recent 3 copies
cd $LOC;
echo "[*] Purging old images.">>$LOGFILE;
echo "[*] $(ls -tp | grep -v '/$' | tail -n +5 )" >>$LOGFILE;
ls -tp | grep -v '/$' | tail -n +4 | xargs -d '\n' -r rm --
echo "[*] Current Image Listing:        $(ls -tp | grep -v '/$' | tail -n3 )" >>$LOGFILE;
echo "[*] Image Backup Complete">>$LOGFILE;

echo "[*]">>$LOGFILE;
echo "[*]">>$LOGFILE;
sudo -u $(who -u| cut -d " " -f1) DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "Local Backup" "Complete @$(date)"
## Decrypt/Decompress
## openssl aes-256-cbc -salt -d -k MYSUPERSECRETPASSWORD -in IMAGE.img.gz -out dec.IMAGE.img.gz
## gunzip dec.IMAGE.img.gz
