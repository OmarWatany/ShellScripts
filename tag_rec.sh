#!/usr/bin/zsh

set -e

file_files_POSTFIX="0"
dump_durations=false
VERBOSE=false

# Create a unique temporary file
file_files="/tmp/file_files_duration${file_files_POSTFIX}.txt"
while [[ -f "$file_files" ]]; do
    file_files_POSTFIX=$(echo "$file_files_POSTFIX + 1" | bc)
    file_files="/tmp/file_files_duration${file_files_POSTFIX}.txt"
done
trap 'rm "$file_files"' EXIT

exts="pdf|epub|djvu|mobi|md"
# Find file files
if command -v fd &>/dev/null; then
    fd -L "\.($exts)" >"$file_files"
else
    echo "fd doesn't Exit"
    exit 1
fi

files_count=$(wc -l <"$file_files")
echo "Files Count $files_count"
total_duration=0
counted=0

tag_file() {
    [[ ${#@} < 1 ]] && exit 1
    tag=$1
    echo $tag
    while read -r file; do
        tmsu tag "$file" --tags $tag
    done <"$file_files"
}

[[ ${#@} < 1 ]] && exit 1
tag_file $1
