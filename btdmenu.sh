#!/bin/bash
#
# dmenu Interface for bluez device basic operations
# require SUDO_ASKPASS variable to be set

# Checks if bluetooth controller is powered on
power_on() {
	return $(bluetoothctl show | grep -q "Powered: yes")
}

# Toggles power state
toggle_power() {
	if power_on; then
		bluetoothctl power off
	else
		if rfkill list bluetooth | grep -q 'blocked: yes'; then
			rfkill unblock bluetooth && sleep 3
		fi
		bluetoothctl power on
	fi
}

contfn() {
	dev=$(echo -e "devices Paired" | bluetoothctl | grep Device | sed -e 's/Device //' | dmenu -l 3)
	echo -e "connect $(echo $dev | awk '{printf $1}')" | bluetoothctl
}

dcontfn() {
	dev=$(echo -e "devices Connected" | bluetoothctl | grep Device | sed -e 's/Device //' | dmenu -l 3)
	echo -e "disconnect $(echo $dev | awk '{printf $1}')" | bluetoothctl
}

if ! power_on; then
	state=$(echo -e "Power On" | dmenu -l 3)
	echo "$state"
	[[ ! $state ]] && exit 0
	toggle_power
fi

state=$(echo -e "Connect\nDisconnect\nPower Off" | dmenu -l 3)
case $state in
Connect) contfn >/dev/null ;;
Disconnect) dcontfn >/dev/null ;;
"Power Off") toggle_power ;;
esac
