#!/bin/bash
scripts=$(fd "" $HOME/scripts/)

FILE=$(echo -e "$scripts" | dmenu -l 10)
[[ -e "$FILE" ]] && sh $FILE
