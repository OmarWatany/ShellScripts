#!/bin/sh

usage() {
	printf "Usage: editToc.sh <command> <filename>\n"
	printf "\tCommands - description   \n"
	printf "\t- dump   - dump toc file \n"
	printf "\t- update - update pdf toc\n"
	printf "\t- help   - show this massege\n"
}

if [[ -e "$2" ]]; then
	filepath="$2"
	tocfile=$(printf "$2" | sed 's/.pdf/.toc/')
else
	usage
	exit
fi

dump() {
	# printf "$tocfile"
	pdftk "$filepath" dump_data_utf8 >$tocfile
	sed -i '/^Bookmark/!d' "$tocfile"
	#      ^
	# delete every line that doesn't start with this battern
}

update() {
	tempfile="temp.pdf"
	pdftk "$filepath" update_info_utf8 "$tocfile" output $tempfile
	rm "$filepath"
	mv "$tempfile" "$filepath"

}

entry() {
	case $1 in
	"dump") dump ;;
	"update") update ;;
	"help" | "usage") usage ;;
	esac
}

entry "$1"
