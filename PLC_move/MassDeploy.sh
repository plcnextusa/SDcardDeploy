#!/bin/bash

export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/plcnext/appshome/bin

string1="$(cat /opt/plcnext/.fwVersion.txt)"
string2="$(head -n 1 /etc/plcnext/arpversion)"
sdState="$(/usr/sbin/sdcard_state.sh getStatus)"

function update() {
  cp -a /opt/plcnext/PLC_move/*.raucb /opt/plcnext/
  cd /opt/plcnext/
  echo "FW Update processing. Please wait."
  sudo update-axcf2152
}

function fileTransfer() {
  sudo /usr/sbin/sdcard_state.sh request_deactivation
  echo "SD card deactivated"
  cp -a /media/rfs/externalsd/upperdir /media/rfs/internalsd
  echo "PLC copied to internal SD"
  sudo reboot
}

function removeFiles() {
  if [ -f /var/spool/cron/PLCmove ]; then
    rm -r /var/spool/cron/PLCmove
  fi
  if [ -f /var/spool/cron/root ]; then
    rm -r /var/spool/cron/root
  fi
  rm -r /opt/plcnext/.fwVersion.txt
  rm -r /opt/plcnext/MassDeploy.sh
  rm -r /opt/plcnext/install.sh
  rm -r /opt/plcnext/PLC_move
  rm -r /media/rfs/externalsd/upperdir/opt/plcnext/logs/PLCmove.log
  if [ -f /opt/plcnext/*.raucb ]; then
    rm -r /opt/plcnext/*.raucb
  fi
  echo "Script files removed. PLC has succesfully been copied."
}

sleep 45

if [ "$string1" != "$string2" ]; then
  update
  exit 0
else
  echo "Same version. FW update not needed."
fi

if [ "$sdState" = "activated" ]; then
  fileTransfer
  exit 0
else
  removeFiles
fi
