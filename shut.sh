#!/bin/dash

state=`echo "Shutdown\nReboot\nSleep\nHibernate" | dmenu -i -p "What to do?"`

prompt(){
	case $state in 
	Shutdown)
		sleep 1;
		shutdown now;
		;;
	Reboot)	
		reboot;
		;;
	Sleep)
		 systemctl suspend ;
		;;
	Hibernate)
		sleep 1;
		systemctl hibernate;
		;;
	*)
		;;
	esac;
}

prompt $stat
