#!/bin/bash

fmfn(){
  ffmpeg -i "$1" -acodec mp3 "$1.mp3"
  # echo "$1";
}

# for I in * ;
# do 
# done
fmfn "$1"
