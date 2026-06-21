#!/usr/bin/bash

# Exit immediately if an unexpected error occurs
set -e

usage() {
    printf "Usage: editToc.sh <command> <filename>\n"
    printf "\tCommands - description   \n"
    printf "\t- dump   - dump toc file \n"
    printf "\t- update - update pdf's toc\n"
    printf "\t- remove - remove pdf's toc\n"
    printf "\t- help   - show this message\n"
}

# Ensure file exists before proceeding
if [[ -f "$2" ]]; then
    filepath="$2"
    # Pure Bash way to replace trailing .pdf with .toc safely
    tocfile="${filepath%.pdf}.toc"
else
    usage
    exit 1
fi

dump() {
    echo "Dumping TOC to $tocfile..."
    cpdf -list-bookmarks "$filepath" > "$tocfile"
}

update() {
    if [[ ! -f "$tocfile" ]]; then
        echo "Error: TOC file ($tocfile) not found! Run dump first." >&2
        exit 1
    fi

    echo "Updating TOC for $filepath..."
    tempfile="temp_update.pdf"

    cpdf -add-bookmarks "$tocfile" "$filepath" -o "$tempfile"
    mv "$tempfile" "$filepath"
}

remove() {
    echo "Removing TOC from $filepath..."
    strip_toc.py "$filepath"
}

entry() {
    case "$1" in
        "dump") dump ;;
        "update") update ;;
        "remove"|"rm") remove ;;
        "help" | "usage") usage ;;
        *) usage ;;
    esac
}

entry "$1"
