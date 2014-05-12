#!/bin/bash

# PiTap
# Automatic bridge creation and packet capture (plug-and-capture) on a battery-powered Raspberry Pi with multiple network interfaces.
# For details on configuration (including other files, such as the Upstart script) see: williamknowles.co.uk/?p=16

# Developer: William Knowles
# Website: williamknowles.co.uk
# Twitter: twitter.com/william_knows

### PATH SETUP
baseDirectory=/home/pi/pitap
captureDirectory=$baseDirectory/captures
logFile=$baseDirectory/pitap.log

### BRIDGE NETWORK INTERFACES
# Create bridge and add interfaces.
brctl addbr bridge0
brctl addif bridge0 eth0
brctl addif bridge0 eth1
# Zero the IP addresses on the interfaces.
ifconfig eth0 0.0.0.0
ifconfig eth1 0.0.0.0
# Start the bridge.
ifconfig bridge0 up

### PACKET CAPTURE
sessionTimestamp=$(date +"session-%d-%m-%y-at-%H-%M")
if [ $1 = "mode1" ]; then
	echo "Starting dump mode at $sessionTimestamp. Captures stored the base directory." >> $logFile
	# MODE 1: WITHOUT sessions.
	# Start capture in the base capture directory.
	tcpdump -i bridge0 -w $captureDirectory/$sessionTimestamp-$RANDOM.pcapng
elif [ $1 = "mode2" ]; then
	# MODE 2: WITH sessions.
	# Create session-specific directory (with timestamp of session start).
	# Captures are rotated every x seconds, and each capture is given a filename based upon the Unix timestamp of when it was created.
	# Used for future development work within the PiTap project.
	# Create session-specific folder based upon tiemstamp.
	mkdir $captureDirectory/$sessionTimestamp
	# Start rotating captures in session-specific folder.
	tcpdump -i bridge0 -w $captureDirectory/$sessionTimestamp-$RANDOM/dump-at-%s.pcapng -G 3600
else
	echo "PiTap has been configured to use an unknown mode!" >> $logFile
fi
