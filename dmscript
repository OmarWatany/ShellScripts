#!/bin/sh
state=`echo -e "Mount\nUnMount"| dmenu -i -p "What do you want ?"`
mnt="$HOME/MTP"
case $state in
    Mount)
        if [[ -d $mnt ]]
        then
            aft-mtp-mount $mnt
        else
            mkdir $mnt &&
            aft-mtp-mount $mnt
        fi ;;
    UnMount)
        fusermount -u $mnt &&
        rmdir $mnt ;;
    *) ;;
esac;
