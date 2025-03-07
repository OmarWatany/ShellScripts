#!/bin/bash

usage() {
	echo "Usage: $0 <book>"
	exit 0
}

files=$(fd ".(pdf|djvu|epub)" $HOME/Documents/)
pdf_readers=("zathura" "FBReader" "epy" "mupdf" "calibre" "apvlv" "sioyek" "xpdf" "atril")
epub_readers=("FBReader" "calibre" "zathura" "mupdf" "apvlv" "sioyek")
book=$(echo -e "$files" | rofi -dmenu -i -theme-str 'window {width: 85%;font : "Iosevka 18";}')

[[ -e "$book" ]] || usage

case "$book" in
*.epub) READERs="${epub_readers[@]}" ;;
*) READERs="${pdf_readers[@]}" ;;
esac

READER=$(for i in ${READERs[@]}; do echo "$i"; done | rofi -dmenu -i -theme-str 'window {width: 85%;font : "Iosevka 18";}')
case "$READER" in
"mupdf") mupdf -C ea9b67 "$book" ;;
"calibre") ebook-viewer --detach "$book" &>/dev/null ;;
"epy") kitty epy "$book" ;;
*) "$READER" "$book" &>/dev/null ;;
esac
