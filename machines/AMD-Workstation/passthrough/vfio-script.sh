#!/bin/bash

# Helpful to read output when debugging
#set -x

##------------------------------------------------------------------------
## Alpha version: 0.4V
## Author: AM(Tobias Rieper)
## Last Edit: 08-01-2023
## Works with AMD GPU with systemd.
## Note: CPU Pinning is disable by default. Check Read Me To enable it ;-)
##-------------------------------------------------------------------------

#Variables
Gen_Vars() {
NULL="/dev/null"
#Delays
Delay_1="1"
Delay_2="2"
Delay_3="3"
Delay_4="4"
Delay_5="5"
##
#Virsh Commands
PCI="pci_0000_"
REMOVE="nodedev-detach"
ADD="nodedev-reattach"
##
#Video and Audio
VIDEO=$(lspci -nn | grep VGA | head -1 | cut -d " " -f1 | tr ":." "_")
VIDEO1=$(lspci -nn | grep VGA | head -1 | cut -d " " -f1)
AUDIO=$(lspci -nn | grep "HDMI Audio" | head -1 | cut -d " " -f1 | tr ":." "_")
AUDIO1=$(lspci -nn | grep "HDMI Audio" | head -1 | cut -d " " -f1)
##
#Display Manager
DM1=$(grep '/usr/s\?bin' /etc/systemd/system/display-manager.service | tr "/" "\n" | tail -1)
DM2=$(ps auxf | awk '{print $11}' | grep -e "dm" | head -1 | tr "/" "\n" | tail -1)
##
#RTC Wake Timer
TIME="+8sec"
##
#CoolDown Delay
Delay_8="8"
##
#Loop Variables
declare -i Loop
Loop=1
declare -i TimeOut
TimeOut=5
##
# Helpful to read output when debugging
set -x
}
Kill_DM() {
	#Just to make sure the session is dead.
	# for i in $(ls /home); do echo $i; killall -u $i;kill -9 $(ps -s -U $i | awk '{print $2}' | grep -Ev "pid");done
	#Fn to  Stop The Display  Manager
	# systemctl start hyprland-logout
	hyprctl dispatch exittex = (pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-medium
              # dvisvgm dvipng # for preview and export as html
              luatex latexmk t2 tempora ccaption soul
              float makecell multirow enumitem cyrillic
              babel babel-russian metafont hyphen-russian
              greek-fontenc;
          });
	#Don't Touch this Delay
	sleep $Delay_2
	#Unbinding VT Consoles if currently bound (adapted from https://www.kernel.org/doc/Documentation/fb/fbcon.txt)
	for i in /sys/class/vtconsole/*;
	do
   		echo 0 > $i/bind
	done
}

IF_AMD() {
    if [ "lsmod | grep "amdgpu" &> /dev/null" ]; then
    lsmod | grep amdgpu | cut -d " " -f1 >/tmp/amd-modules
	#Syncing Disk and clearing The Caches(RAM)
	sync; echo 1 > /proc/sys/vm/drop_caches
	#Un-Binding GPU From driver
	sleep $Delay_2
	echo "0000:$VIDEO1" > "/sys/bus/pci/devices/0000:$VIDEO1/driver/unbind"
    echo "0000:$AUDIO1" > "/sys/bus/pci/devices/0000:$AUDIO1/driver/unbind"
	#Waiting for AMD GPU To Fininsh
	while ! (dmesg | grep "amdgpu 0000:$VIDEO1" | tail -5 | grep "amdgpu: finishing device."); do echo "Loop-1"; if [ "$Loop" -le "$TimeOut" ]; then echo "Waiting"; TimeOut+=1; echo "Try: $TimeOut"; sleep 1; else break;fi; done
	## Removing Video and Audio
	virsh $REMOVE "$PCI$VIDEO"
	sleep 1
	virsh $REMOVE "$PCI$AUDIO"
	modprobe -r amdgpu
	#Reseting The Loop Counter
	Loop=1
	#Making Sure that AMD GPU is Un-Loaded
	while (lsmod | grep amdgpu); do echo "Loop-3"; if [ "$Loop" -le "$TimeOut" ]; then echo "AMD GPU in use"; lsmod | grep amdgpu | awk '{print $1}' | while read AM; do modprobe -r $AM; done;TimeOut+=1; echo "AMDGPU try: $TimeOut"; sleep 1; else echo "Fail To Remove AMD GPU";rmmod amdgpu; break;fi;done
    #may the force be with you
	#rmmod -f amdgpu
	#garbage collection
	unset Loop
	unset TimeOut
	#Putting System To a quick sleep cycle to make sure that amd graphic card is Properly reset
	rtcwake -m mem --date $TIME

    fi
}
CPU_Pining() {
if [[ "$*" == "enable" ]]
then
	systemctl set-property --runtime -- user.slice AllowedCPUs=0,8
	systemctl set-property --runtime -- system.slice AllowedCPUs=0,8
	systemctl set-property --runtime -- init.scope AllowedCPUs=0,8
	echo "CPU Pining Enabled"
elif [[ "$*" == "disable" ]]
then
	systemctl set-property --runtime -- user.slice AllowedCPUs=0-11
	systemctl set-property --runtime -- system.slice AllowedCPUs=0-11
	systemctl set-property --runtime -- init.scope AllowedCPUs=0-11
	echo "CPU Pining Disable"
fi
}
# Main Init
if [[ "$*" == "start" ]]
then
	Gen_Vars
	Kill_DM
	IF_AMD
	#CPU_Pining "enable"
    echo "Start Done"
elif [[ "$*" == "stop" ]]
then
	Gen_Vars
	#CPU_Pining "disable"
    echo "1" | tee -a /sys/bus/pci/devices/0000:$AUDIO1/remove
	echo "1" | tee -a /sys/bus/pci/devices/0000:$VIDEO1/remove
	rtcwake -m mem --date $TIME
	sleep  $Delay_3
	echo "1" | tee -a /sys/bus/pci/rescan
	# systemctl restart  `cat /var/tmp/Last-DM`
	echo "Stop Done"
fi
