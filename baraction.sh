#!/bin/sh
# baraction.sh for spectrwm status bar
# AUTHOR: dt

## DISK
hdd() {
	hdd1="$(df -h | awk 'NR==4{print $3, $5}')"
	hdd2="$(df -h | awk 'NR==7{print $3, $5}')"
	echo -e "SDD: R: $hdd1 H: $hdd2"
}

## RAM
mem() {
	mem=$(free | awk '/Mem/ {printf "%dM/%dM\n", $3 / 1024.0, $2 / 1024.0 }')
	echo -e "$mem"
}

## CPU
cpu() {
	read cpu a b c previdle rest </proc/stat
	prevtotal=$((a + b + c + previdle))
	sleep 0.5
	read cpu a b c idle rest </proc/stat
	total=$((a + b + c + idle))
	cpu=$((100 * ((total - prevtotal) - (idle - previdle)) / (total - prevtotal)))
	echo -e "CPU: $cpu%"
}

## VOLUME
vol() {
	vol=$(amixer get Master | awk -F'[][]' 'END{ print $4":"$2 }' | sed 's/on://g')
	echo -e "VOL: $vol"
}

bat() {
	status=$(upower -i $(upower -e | grep BAT) | awk 'NR==12{print $2}')
	bat=$(upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}')
	if [ "$status" = "charging" ]; then
		echo -e "BAT: $bat Chrg"
	else
		echo -e "BAT: $bat"
	fi
}

SLEEP_SEC=3
#loops forever outputting a line every SLEEP_SEC secs

# It seems that we are limited to how many characters can be displayed via
# the baraction script output. And the the markup tags count in that limit.
# So I would love to add more functions to this script but it makes the
# echo output too long to display correctly.
while :; do
	echo "$(bat) | +@fg=1; +@fn=1;💻+@fn=0; $(cpu) +@fg=0; | +@fg=2; +@fn=1;💾+@fn=0; $(mem) +@fg=0; | +@fg=3; +@fn=1;💿+@fn=0; $(hdd) +@fg=0; | +@fg=4; +@fn=1;🔈+@fn=0; $(vol) +@fg=0; |"
	sleep $SLEEP_SEC
done
