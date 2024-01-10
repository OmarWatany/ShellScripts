#!/bin/bash
#
# dmenu Interface for bluez device basic operations
# require SUDO_ASKPASS variable to be set

btc=`systemctl status bluetooth | awk '/Active/ {printf $2}'`

if [ $btc = "inactive" ]
  then 
    sudo -A systemctl start bluetooth && state=`echo -e "Connect\nDisconnect\nExit" | dmenu -l 3 -i`;
  else
    state=`echo -e "Connect\nDisconnect\nExit" | dmenu -l 3 -i`
fi;

contfn(){
dev=`echo -e "devices Paired" | bluetoothctl | grep Device | sed -e 's/Device //'  | dmenu -l 3 -i`
echo -e "connect $(echo $dev | awk '{printf $1}')" | bluetoothctl;
}

dcontfn(){
dev=`echo -e "devices Connected" | bluetoothctl | grep Device | sed -e 's/Device //'  | dmenu -l 3 -i`
echo -e "disconnect $(echo $dev | awk '{printf $1}')" | bluetoothctl;
}

case $state in 
  Connect) contfn > /dev/null ;; 
  Disconnect) dcontfn > /dev/null ;;
  Exit) sudo -A systemctl stop bluetooth ;;
esac

