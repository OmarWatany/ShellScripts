#!/usr/bin/bash

device=$(kdeconnect-cli -a --name-only | dmenu)
echo "$@"
kdeconnect-cli --name "$device" --share "$@"
