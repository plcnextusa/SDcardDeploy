#!/bin/bash

export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/plcnext/appshome/bin

versionString=$(grep Arpversion /etc/plcnext/arpversion)
version="${versionString//[^0-9]/}"

if [ "$version" -ge 2400000 ]; then
  PS3='Please enter your choice: '
  options=("1: SD Card activated after reset" "2: SD Card retains current setting after reset" "Quit")
  select opt in "${options[@]}"
  do
    case $opt in
        "1: SD Card activated after reset")
            echo "SD card will be active after reset"
            touch /opt/plcnext/.reactive.txt
	    if  [ ! -f /etc/device_data/boot_settings/sd_reactivation ]; then
	      touch /etc/device_data/boot_settings/sd_reactivation
	      chown plcnext_firmware /etc/device_data/boot_settings/sd_reactivation
	      chmod 664 /etc/device_data/boot_settings/sd_reactivation
	    fi
            break
            ;;
        "2: SD Card retains current setting after reset")
            echo "You chose Option 2"
            break
            ;;
        "Quit")
            exit
            ;;
        *) echo "Invalid option $REPLY";;
    esac
  done
fi

#Check for new update
if [ -d /opt/plcnext/PLC_move ]; then
	mv /opt/plcnext/*.raucb /opt/plcnext/PLC_move/
	cp -a /opt/plcnext/PLC_move/MassDeploy.sh /opt/plcnext/
	chmod 777 /opt/plcnext/MassDeploy.sh
	cp -a /opt/plcnext/PLC_move/PLCmove /var/spool/cron/
	sudo crontab /var/spool/cron/PLCmove
	cd /opt/plcnext
	fwVersion="$(head -n 1 /etc/plcnext/arpversion)"
	echo "$fwVersion" > /opt/plcnext/.fwVersion.txt
	echo "Running script to move files. Please wait."
	./MassDeploy.sh
else
	echo "No files found."
fi
