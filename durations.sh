#!/usr/bin/zsh
VERSION="0.5.2"

counted=0
files_count=0
total_duration=0
VERBOSE=false
single_video=false
dump_durations=false
dump_file="./dump_durations.txt"
# Create a unique temporary file
video_files="$(mktemp -t "video_files.XXXXXX")"
output_file="/dev/null"

# Usage function
usage() {
    echo "Usage: $0 [-hdv] [-D <file>]"
    echo "  -d: Dump each file's duration into default_file."
    echo "  -D: Dump each file's duration into <file>."
    echo "  -f: Get <file's> duration."
    echo "  -h: Print this usage message."
    echo "  -v: Verbose."
    echo "  -o: output file"
    exit 1
}

cleanup() {
    echo "\nReceived signal. Cleaning up..."
    [[ -f "$video_files" ]] && rm "$video_files"
    exit 0
}

trap cleanup SIGINT SIGTERM SIGHUP

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
    formatted_secs=$(date -u -d "@$1" +"%H:%M:%S")
    printf "$formatted_secs\n"
}

calculate_dur() {
    while read -r video; do
        if [[ ! -f "$video" ]]; then
            "$VERBOSE" && echo -e "\e[31m$video NOT FOUND\e[0m"
            duration="0"
            continue
        fi

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
        total_duration=$(echo "$total_duration + $duration" | bc)

    done <"$1"
}

pad=("4" "2")
# parameter "duration"
print_durations() {
    max=("0" "0")
    factors=("1.0" "1.25" "1.500" "2.0000" "2.500" "3.00" "4.0")
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

    [[ ${max[1]%.*} -gt 10   ]] && pad[1]="5" # hrs >= 10    -> pad[1] = 5
    [[ ${max[1]%.*} -gt 100  ]] && pad[1]="6" # hrs >= 100   -> pad[1] = 6
    [[ ${max[1]%.*} -gt 1000 ]] && pad[1]="7" # hrs >= 1000  -> pad[1] = 7

    # Handle the specific day-related override 
    # days >= 100 -> hrs >= 2400
    [[ ${max[1]%.*} -gt 1000 && ${max[2]%.*} -gt 100 ]] && pad[2]="3"

    for i in {1..${#factors}}; do
        formatted_secs=$(date -u -d "@${d_list[$i]}" +"%H:%M:%S")
        days_format=$(printf "%0${pad[2]}d:" "${days_list[$i]}")
        hrs_format=$(printf "%-${pad[1]}.2f" "${hrs_list[$i]}")

        printf "$days_format$formatted_secs ( $hrs_format ) x${factors[$i]}\n"
    done

    uncounted=$((files_count - counted))
    printf "Total A/V count   : %d\n" "$files_count"
    printf "Counted Files     : %d\n" "$counted"
    printf "Uncounted Files   : %d\n" "$uncounted"
}

# Parse command-line arguments
while getopts ":dhvxo:f:D:" opt; do
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
    if [[ $opt = 'f' ]]; then 
        single_video=true
        echo "$OPTARG" > $video_files
    fi
    if [[ $opt = 'o' ]]; then 
        output_file="$OPTARG"
    fi
done

if ! $single_video ; then
    # Find video files
    if ! command -v fd &>/dev/null; then
        echo "fd Doesn't exist"
        exit 1
    fi
    fd -L "\.(mp4|webm|mkv|m4a|mov|3gp|mj2|mp3|opus|aac|flac)" -E tmsu -E WhatsApp >"$video_files"
fi

files_count=$(wc -l <"$video_files")

# echo "$output_file"
calculate_dur "$video_files"
print_durations | tee "$output_file"
[[ -f "$video_files" ]] && rm "$video_files"
