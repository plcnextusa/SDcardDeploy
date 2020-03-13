#!/bin/bash

export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/plcnext/appshome/bin

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
