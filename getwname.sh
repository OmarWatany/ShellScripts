#!/bin/sh
#

app=`xprop | awk '/^WM_CLASS\(/ {printf $NF}'| sed 's/\"//g'`
notify-send "$app"
