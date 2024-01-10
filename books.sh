#!/bin/bash
fil=`fd ".pdf|.djvu" $HOME/Documents/ `

FILE=`echo -e "$fil" | dmenu -i -l 20`
if [[ -e "$FILE" ]]
then
    READER=`echo -e "zathura\nmupdf\nsioyek\nxpdf\natril" | dmenu -i -l 3`
    case "$READER" in
        "zathura") zathura "$FILE" ;;
        "mupdf") mupdf -C ea9b67 "$FILE" ;;
        "sioyek") sioyek "$FILE" ;;
        "xpdf") xpdf "$FILE" ;;
        "atril") atril "$FILE" ;;
        *) xdg-open "$FILE" ;;
    esac;
fi
