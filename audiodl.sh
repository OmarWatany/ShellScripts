#!/bin/bash
#
# TODO "handle if there isn't url in the clipboard"

# script for downloading music/audio files with the ability to change its tags 
mdir="$HOME/Music/"
vdir="$HOME/Videos/"
typ=`echo -e "audio\nvideo\nbest" | dmenu -i`

audiofn(){
  src=`yt-dlp -F $(xclip -o | sed 's/&list*.*//')| grep "audio only" | dmenu -i -l 5 -p "which resolution ?" `;
  res=`echo $src | awk '{printf $1}'`
  bit=`echo $src | awk '{printf $8}'`
  fil=`yt-dlp -f $res $(xclip -o) -o "$mdir/%(fulltitle)s" | grep "Destination" | sed 's/.*:\ //'`
  ffmpeg -i "$fil" -vn -ar 44100 -ac 2 -b:a $bit "$fil.mp3" && rm "$fil"
}

vidfn(){
  src=`yt-dlp -F $(xclip -o)| grep "video only" | dmenu -i -l 5 -p "which resolution ?" `;
  res=`echo $src | awk '{printf $1}'`
  fil=`yt-dlp -f $res $(xclip -o) -o "$vdir/%(fulltitle)s.%(ext)s" 
}

bestfn(){
  src=`yt-dlp -F $(xclip -o)| grep "~" | dmenu -i -l 3 -p "which resolution ?" `;
  res=`echo $src | awk '{printf $1}'`
  fil=`yt-dlp -f $res $(xclip -o) -o "$vdir/%(fulltitle)s.%(ext)s" 
  # mv $fil $vidr/"$NAME"
}

case $typ in 
  audio) audiofn ;;
  video) vidfn ;;
  best) bestfn ;;
esac;
  
