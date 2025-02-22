#!/usr/bin/bash

shopt -s extglob

video_files="./video_files_for_subs.txt"
[[ -f "$video_files" ]] && exit
fd ".mp4|.webm|.mkv" >$video_files

SUB_EXT="$2"
SUB_POSTFIX="$1"

convert() {
	vid=$1
	VIDEO_EXT="${vid##*.}"
	case "$VIDEO_EXT" in
	"webm") base_name=$(basename -- "$vid" .webm) ;;
	"mp4") base_name=$(basename -- "$vid" .mp4) ;;
	"mkv") base_name=$(basename -- "$vid" .mkv) ;;
	*)
		echo -e "\e[34m$VIDEO_EXT UNSUPPORTED\e[0m"
		return
		;;
	esac
	echo -e "\e[32m$vid\e[0m"
	dir=$(dirname -- "$vid")
	sub="$dir/$base_name""$SUB_POSTFIX""$SUB_EXT"
	out="$dir/$base_name""_en.""$VIDEO_EXT"
	if [[ -f "$sub" && ! -f "$out" ]]; then
		case "$VIDEO_EXT" in
		"webm") SUB_CODEC="webvtt" ;;
		"mp4") SUB_CODEC="mov_text" ;;
		"mkv") SUB_CODEC="srt" ;;
		esac
		arsub="$dir/$base_name"".ar""$SUB_EXT"
		if [[ -f "$arsub" ]]; then
			ffmpeg -i "$vid" -i "$sub" -i "$arsub" \
				-map 0:v -map 0:a -map 1 -map 2 \
				-c:v copy -c:a copy -c:s $SUB_CODEC \
				-metadata:s:s:0 language=eng -metadata:s:s:0 title=English \
				-metadata:s:s:1 language=ara -metadata:s:s:1 title=Arabic "$out" &>/dev/null
		else
			ffmpeg -i "$vid" -i "$sub" \
				-map 0:v -map 0:a -map 1 \
				-c:v copy -c:a copy -c:s $SUB_CODEC \
				-metadata:s:s:0 language=eng -metadata:s:s:0 title=English "$out" &>/dev/null
			# -metadata:s:s:0 language=eng -metadata:s:s:0 title=English "$out"
		fi
		if [[ $(du "$out" | cut -f 1) -ge $(du "$vid" | cut -f 1) ]]; then
			rm -v "$sub" "$vid"
			[[ -f "$arsub" ]] && rm -v "$arsub"
			rename "_en" "" "$out"
		fi
	elif [[ -f "$out" ]]; then
		echo -e "$out \e[33mEXIST\e[0m"
	else [[ ! -f "$sub" ]] && echo -e "$sub \e[31mNOT FOUND\e[0m"; fi
}

while read -r line; do
	[[ -f "$line" ]] && convert "$line"
done <"$video_files"

rm -v "$video_files"
