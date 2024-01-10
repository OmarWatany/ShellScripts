#!/bin/bash

# Script to bring non visible sticky windows over
# to the current tag
# from redit

hc() {
    herbstclient "$@"
}

hc lock

read -ra other_monitor <<< "$(hc tag_status | tr '\t' '\n' | sed -n 's/-//p')"
declare -A other_monitor_map
for key in "${!other_monitor[@]}"; do other_monitor_map[${other_monitor[$key]}]="$key"; done

win_ids=$(hc foreach T clients. \
        sprintf S "%c.my_sticky_client" T \
        and . silent compare S "=" "true" \
        . sprintf WINIDATTR "%c.winid" T \
    attr WINIDATTR 2>&1) # Not sure why this is only printed properly in stderr, is it a bug? or because of silent?
win_array=($win_ids)

for sticky_winid in "${win_array[@]}"; do
    tag=$(hc attr "clients.$sticky_winid.tag")
    if [ ! ${other_monitor_map[$tag]+_} ]; then hc bring "$sticky_winid"; fi
done

hc unlock
