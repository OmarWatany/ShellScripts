#!/bin/bash

choose=$(echo -e "restore\ncopy\nmove\ntest" | fzy)

bakD=$(ls -1 ~/Dev/bak/ | fzy)
lshare="$HOME/Dev/bak/$bakD/lshare/"
lstate="$HOME/Dev/bak/$bakD/lstate/"
conf=  "$HOME/Dev/bak/$bakD/conf/"

backup_folders=("$lshare" "$lstate" "$conf")
working_folders=("$HOME/.local/share/nvim/" "$HOME/.local/state/nvim/" "$HOME/.config/nvim/")

num=(0 1 2)

if [ "$choose" = "copy" ]; then
    for i in ${num[@]}; do
        bfolder=${backup_folders[i]}
        rfolder=${working_folders[i]}
        if [ ! -d "$bfolder" ]; then
            mkdir -p "$bfolder" && echo "$bfolder created"
            cp -r "$rfolder/*" "$bfolder" && echo "$rfolder ->> $bfolder"
        else
            cp -r "$rfolder/*" "$bfolder" && echo "$rfolder ->> $bfolder"
        fi
    done

elif [ "$choose" = "move" ]; then
    for i in ${num[@]}; do
        bfolder=${backup_folders[i]}
        rfolder=${working_folders[i]}
        if [ ! -d "$bfolder" ]; then
            mkdir -p "$bfolder" && echo "$bfolder created"
            mv "$rfolder/*" "$bfolder" && echo "$rfolder -> $bfolder"
        else
            mv "$rfolder/*" "$bfolder" && echo "$rfolder -> $bfolder"
        fi
    done

elif [ "$choose" = "restore" ]; then
    for i in ${num[@]}; do
        bfolder="${backup_folders[i]}"
        rfolder="${working_folders[i]}"
        if [ ! -d "$rfolder" ]; then
            mkdir -p "$rfolder" && echo "$rfolder created"
        else
            cp -r "$bfolder" "$rfolder" # && echo "$bfolder ->> $rfolder"
        fi
    done

elif [ "$choose" = "test" ]; then
    scndchos=$(echo -e "restore\ncopy\nmove\ntest" | fzy)
    if [ "$scndchos" = "restore" ]; then
        for i in ${num[@]}; do
            echo "${backup_folders[i]} -> ${working_folders[i]}"
        done
    elif [ "scndchos" = "copy" ]; then
        for i in ${num[@]}; do
            echo "${working_folders[i]} -> ${backup_folders[i]}"
        done
    fi
fi
