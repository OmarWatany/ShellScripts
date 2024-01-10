#!/bin/bash
fil=`fd ".epub" $HOME/Documents/ `
#

FILE=`echo -e "$fil" | fzy`
if [[ -e "$FILE" ]]
then
    READER=`echo -e "epy\nepr\nFBReader\nokular" | fzy`
    case "$READER" in
        "epy") epy "$FILE" ;;
        "epr") epr "$FILE" ;;
        "okular" ) okular "$FILE" > /dev/null & disown ;;
        "FBReader" ) setsid FBReader "$FILE" > /dev/null & ;;
        *) xdg-open "$FILE" ;;
    esac;
fi
