#!/bin/bash

fm=`printf "nnn\nlfrun\nvifm\nnemo\npcmanfm\nthunar\ndolphin" | dmenu -p "Which File Manager" `

if [[ -n "$fm" ]] ;then
    fldr=`printf "coding\ncpp\nsrc\nuni" | dmenu -p 'Jump to'`

    [[ -n "$fldr" ]] && jfldr=`autojump $fldr` || jfldr=""

    case "$fm" in
        "pcmanfm"|"nemo"|"thunar"|"dolphin")
            $fm "$jfldr" &> /dev/null
            ;;
        "lfrun"|"nnn"|"vifm")
            st -T "fileManager" -e bicon.bin $fm $jfldr &> /dev/null
            ;;
    esac;
fi
