#!/usr/bin/zsh
VERSION="0.5.0"

video_files_POSTFIX="0"
dump_durations=false
VERBOSE=false
dump_file="./dump_durations.txt"

# Usage function
usage() {
    echo "Usage: $0 [-hdv] [-D <file>]"
    echo "  -d: Dump each file's duration into default_file."
    echo "  -D: Dump each file's duration into <file>."
    echo "  -h: Print this usage message."
    echo "  -v: Verbose."
    exit 1
}

# Parse command-line arguments
while getopts ":dhvx:D:" opt; do
    [[ $opt = 'h' ]] && usage
    [[ $opt = 'v' ]] && VERBOSE=true
    [[ $opt = 'x' ]] && set -x
    if [[ $opt = 'D' ]]; then
        [ "$OPTARG" ] && dump_file="$OPTARG"
        echo "dumping to $dump_file"
        printf "" >"$dump_file"
        dump_durations=true
    fi
    if [[ $opt = 'd' ]]; then
        printf "" >"$dump_file"
        dump_durations=true
    fi
done

# Create a unique temporary file
video_files="/tmp/video_files_duration${video_files_POSTFIX}.txt"
while [[ -f "$video_files" ]]; do
    video_files_POSTFIX=$(echo "$video_files_POSTFIX + 1" | bc)
    video_files="/tmp/video_files_duration${video_files_POSTFIX}.txt"
done

cleanup() {
    echo "\nReceived signal. Cleaning up..."
    [[ -f "$video_files" ]] && rm "$video_files"
    exit 0
}

trap cleanup SIGINT SIGTERM SIGHUP

# Find video files
if command -v fd &>/dev/null; then
    fd -L "\.(mp4|webm|mkv|m4a|mov|3gp|mj2|mp3|opus|aac|flac)" -E tmsu -E WhatsApp >"$video_files"
else
    echo "fd Doesn't EXIST"
    exit 1
fi

files_count=$(wc -l <"$video_files")
total_duration=0
counted=0

reset_values() {
    files_count=$(wc -l <"$video_files")
    total_duration=0
    counted=0
}

get_dirs() {
    dirs=()
    while read -r file; do
        dir=$(dirname -- "$file")
        [[ ! " ${dirs[@]} " =~ " $dir " ]] && dirs+=("$dir")
    done <"$video_files"
    echo "${dirs[@]}"
}

format_duration() {
    [[ ${#@} < 1 ]] && return
    formated_secs=$(date -u -d "@$1" +"%H:%M:%S")
    printf "$formated_secs\n"
}

calculate_dur() {
    while read -r video; do
        if [[ -f "$video" ]]; then
            if "$VERBOSE"; then
                echo -e "\e[32m$video \e[33m [ $counted\\$files_count ]\e[0m"
                duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video")
            else
                printf "\e[33mProgress [ %d\\%d ]\e[0m\r" "$counted" "$files_count"
                duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video" 2>/dev/null)
            fi
            if $dump_durations; then
                output=$(format_duration "$duration")
                echo "$output -> $video" >>"$dump_file"
            fi
            counted=$((counted + 1))
        else
            "$VERBOSE" && echo -e "\e[31m$video NOT FOUND\e[0m"
            duration="0"
        fi
        total_duration=$(echo "$total_duration + $duration" | bc)
    done <"$1"
}

pad=("4" "2")
# parameter "duration"
print_durations() {
    max=("0" "0")
    factors=("1" "2" "1.5" "1.25" "0.5" "3" "4")
    days_list=()
    hrs_list=()
    d_list=()
    for f in "${factors[@]}"; do
        factored_d=$(echo "$total_duration / $f" | bc)
        factored_d=${factored_d%.*}
        d_list+=($factored_d)

        hrs=$(echo "scale=5; $factored_d / 3600" | bc)
        hrs_list+=($hrs)
        [[ ${hrs%.*} -gt ${max[1]%.*} ]] && max[1]="$hrs"

        days=$((factored_d / 86400))
        days_list+=($days)
        [[ "${days%.*}" -gt "${max[2]%.*}" ]] && max[2]="$days"
    done
    # max[1] -> hrs , max[2] -> days
    if [[ ${max[1]%.*} -gt "10" ]]; then # hrs >= 10  -> pad[1] = 5
        pad[1]="5"
        if [[ ${max[1]%.*} -gt "100" ]]; then # hrs >= 100  -> pad[1] = 6
            pad[1]="6"
            if [[ ${max[1]%.*} -gt "1000" ]]; then # hrs >= 1000  -> pad[1] = 7
                pad[1]="7"
                [[ ${max[2]%.*} -gt "100" ]] && pad[2]="3" # days >= 100 -> hrs >= 2400
            fi
        fi
    fi

    for i in {1..${#factors}}; do
        formated_secs=$(date -u -d "@${d_list[$i]}" +"%H:%M:%S")
        days_format=$(printf "%0${pad[2]}d:" "${days_list[$i]}")
        hrs_format=$(printf "%-${pad[1]}.2f" "${hrs_list[$i]}")

        printf "$days_format$formated_secs ( $hrs_format ) x${factors[$i]}\n"
    done

    uncounted=$((files_count - counted))
    printf "Total A/V count   : %d\n" "$files_count"
    printf "Counted Files     : %d\n" "$counted"
    printf "Uncounted Files   : %d\n" "$uncounted"
}

calculate_dur "$video_files"
print_durations
[[ -f "$video_files" ]] && rm "$video_files"
