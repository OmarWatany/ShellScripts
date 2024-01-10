#!/bin/dash

pro=`printf "Full\nWindow\nActive\n" | dmenu -i -p "Which type ?"`

screensh() {
	case $pro in 
	Full)
		scrot -m ~/Pictures/Screenshots/%d-%m-%Y-%T.png
                ;;
        Window)
                scrot -s ~/Pictures/Screenshots/%d-%m-%Y-%T.png
                ;;
	Active)
		scrot -u ~/Pictures/Screenshots/%d-%m-%Y-%T.png
		;;
        --version)
                echo "4.0"
                ;;
        *)
                ;;
        esac;
}

screensh $pro

