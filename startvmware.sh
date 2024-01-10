#!/bin/bash

if [ "$1" == "start" ]  || [ "$1" == "Start" ]
then
	sudo systemctl start vmware-networks.service  ;
	sudo systemctl start vmware-usbarbitrator.service ;
	modprobe -a vmw_vmci vmmon;
elif [ "$1" == "stop" ] || [ "$1" == "Stop" ]
then
	sudo systemctl stop vmware-networks.service  ;
	sudo systemctl stop vmware-usbarbitrator.service ;
else
	echo "Options :";
	echo "         start";
	echo "         stop";
fi

