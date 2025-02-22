#!/usr/bin/bash

# backup documents folder
# rsync -avhP --delete $HOME/Documents/ /media/exdrive/Documents

DST_PREFIX="$HOME/Phone"
SRC_PREFIX="$HOME/sshfs/mobile"

FOLDERS=("backups" "SwiftBackup" "Manga" "Download" "WhatsApp")
FOLDERS_SRC_PREFIX=("" "" "" "" "Android/media/com.whatsapp/")

for i in ${!FOLDERS[@]}; do
	DST="$DST_PREFIX/${FOLDERS[$i]}/"
	SRC="$SRC_PREFIX/${FOLDERS_SRC_PREFIX[$i]}${FOLDERS[$i]}/"
	case $1 in
	"dry")
		rsync -arhv --dry-run --delete $SRC $DST
		;;
	"run")
		rsync -arhv --delete $SRC $DST
		;;
	"phone_dry")
		rsync -arhv --dry-run --delete $DST $SRC
		;;
	"phone_run")
		rsync -arhv --delete $DST $SRC
		;;
	*)
		# rsync -arhv $@ $SRC $DST
		;;
	esac
done
