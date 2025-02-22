#!/bin/sh

brightness(){

	case $1 in 
	INC)
		light -A 10
		;;
	DEC) 
		light -U 10
		;;
	*)
		;;
	esac;
}

brightness $1
