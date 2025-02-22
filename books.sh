#!/bin/bash

fil=$(fd ".(pdf|djvu|epub)" $HOME/Documents/)
PDF_READERS=("zathura" "FBReader" "epy" "mupdf" "calibre" "apvlv" "sioyek" "xpdf" "atril")
EPUB_READERS=("FBReader" "calibre" "zathura" "mupdf" "apvlv" "sioyek")
BOOK=$(echo -e "$fil" | rofi -dmenu -i -theme-str 'window {width: 85%;font : "Iosevka 18";}')

# FILE=`echo -e "$fil" | dmenu -l 20`
if [[ -e "$BOOK" ]]; then
	case "$BOOK" in
	*.epub) READERs="${EPUB_READERS[@]}" ;;
	*) READERs="${PDF_READERS[@]}" ;;
	esac
	READER=$(for i in ${READERs[@]}; do echo "$i"; done | rofi -dmenu -i)
	case "$READER" in
	"mupdf") mupdf -C ea9b67 "$BOOK" ;;
	"calibre") ebook-viewer --detach "$BOOK" &>/dev/null ;;
	"epy") kitty epy "$BOOK" ;;
	*) "$READER" "$BOOK" &>/dev/null ;;
	esac
fi
