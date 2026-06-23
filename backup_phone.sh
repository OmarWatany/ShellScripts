#!/usr/bin/bash

# backup documents folder
# rsync -avhP --delete $HOME/Documents/ /media/exdrive/Documents

DST_PREFIX="$HOME/Phone"
SRC_PREFIX="$HOME/fuse_mount/mobile"


# FOLDERS=("backups" "SwiftBackup" "Download" "Manga" "Videos" "WhatsApp")
# FOLDERS_SRC_PREFIX=("" "" "" "" "" "Android/media/com.whatsapp/")

FOLDERS=("SwiftBackup" "Download" "Manga" "Videos")
FOLDERS_SRC_PREFIX=("" "" "" "")
for i in ${!FOLDERS[@]}; do
	DST="$DST_PREFIX/${FOLDERS[$i]}"
	SRC="$SRC_PREFIX/${FOLDERS_SRC_PREFIX[$i]}${FOLDERS[$i]}/" #rsync

	case $1 in
	"dry")
    echo -e "\e[32m|>\e[0m SRC: $SRC, DST: $DST"
		rsync -arhv --dry-run --delete $SRC $DST
		;;
	"run")
    echo -e "\e[32m|>\e[0m SRC: $SRC, DST: $DST"
		rsync -arhvP --delete $SRC $DST
		;;
	"phone_dry")
    echo -e "\e[32m|>\e[0m SRC: $DST, DST: $SRC"
		rsync -arhv --dry-run --delete "$DST/" $SRC
		;;
	"phone_run")
    echo -e "\e[32m|>\e[0m SRC: $DST, DST: $SRC"
		rsync -arhvP --delete "$DST/" $SRC
		;;
	*)
		echo "Command Not Valid $1"
		# rsync -arhv $@ $SRC $DST
		;;
	esac
done
