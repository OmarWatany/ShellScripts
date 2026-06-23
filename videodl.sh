#!/bin/bash
#
# TODO: "handle if there isn't url in the clipboard"
#
set -e

# script for downloading music/audio files with the ability to change its tags
mdir="$HOME/Videos/"
vdir="$HOME/Videos"
typ=$(echo -e "best\nvideo\naudio" | fzy)
[[ ! -d "$vdir" ]] && mkdir "$vdir"
[[ ! -d "$mdir" ]] && mkdir "$mdir"

bestfn() {
	list=$(yt-dlp -F $(xclip -o))
	vd=$(echo "$list" | grep "video only" | fzy | awk '{printf $1}')
	ad=$(echo "$list" | grep "audio only" | fzy | awk '{printf $1}')
	yt-dlp --sub-lang "en" --write-auto-subs --embed-subs --embed-chapters -f $vd+$ad $(xclip -o) -o "$vdir/%(fulltitle)s.%(ext)s"

}

audiofn() {
	src=$(yt-dlp -F $(xclip -o | sed 's/&list*.*//') | grep "audio only" | fzy)
	res=$(echo $src | awk '{printf $1}')
	bit=$(echo $src | awk '{printf $8}')
	fil=$(yt-dlp --sub-lang "en" --write-auto-subs --embed-subs --embed-chapters -f $res $(xclip -o) -o "$mdir/%(fulltitle)s" | grep "Destination" | sed 's/.*:\ //')
	ffmpeg -i "$fil" -vn -ar 44100 -ac 2 -b:a $bit "$fil.mp3" && rm "$fil"
}

vidfn() {
	src=$(yt-dlp -F $(xclip -o) | grep "video only" | fzy -l 5 -p "which resolution ?")
	res=$(echo $src | awk '{printf $1}')
	yt-dlp --sub-lang "en" --write-auto-subs --embed-subs --embed-chapters -f $res $(xclip -o) -o "$vdir/%(fulltitle)s.%(ext)s"
}

resfn() {
	res=$(echo -e "1080\n720\n480\n360\n144" | fzy)
	src=$(yt-dlp -F $(xclip -o) | grep $res | fzy -l 5 -p "which one ?")
	handler=$(echo "$src" | awk '{printf $1}')
	yt-dlp --sub-lang "en" --write-auto-subs --embed-subs --embed-chapters -f $handler $(xclip -o) -o "$vdir/%(fulltitle)s.%(ext)s"
}

case $typ in
audio) audiofn ;;
video) vidfn ;;
best) bestfn ;;
	# res) resfn;;
esac
