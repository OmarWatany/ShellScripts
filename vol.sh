#!/bin/sh
sink=@DEFAULT_SINK@

vol(){
	case $1 in 
	INC)
		pactl set-sink-volume "$sink" +10%;
		;;
	DEC)
		pactl set-sink-volume $sink -10%;
		;;
	Mute)
		pactl set-sink-mute $sink toggle;
		;;
	*)
		;;
	esac;
}
vol $1
