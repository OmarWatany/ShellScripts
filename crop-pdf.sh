#!/usr/bin/bash

# Exit immediately if any command fails
set -e

# Check if an argument was provided
if [ -z "$1" ]; then
    echo "Error: Please provide a PDF file."
    exit 1
fi

echo "$1"
input_file="$1"
filename="$(basename -- "$input_file" .pdf)"

# Define temporary pipeline names and final desired names
cropped_file="${filename}_cropped.pdf"
final_pdf="${filename}_crop.pdf"
final_toc="${filename}_crop.toc"

# 1. Dump the TOC. This creates "${filename}.toc"
editToc.sh dump "$input_file"

# 2. Run the cropping tool (outputs ${filename}_cropped.pdf)
# pdfcropmargins -ch -t 100 -pg "$2" "$input_file"
pdfcropmargins -ch -pg "$2" "$input_file"

# 3. Scale it to uniform width (outputs ${filename}_crop.pdf)
pdfuniw.py "$cropped_file" "$final_pdf" -p "$2"

# 4. TRICK: Temporarily copy the .toc file to match the final PDF's name
# so editToc.sh sees "${filename}_crop.toc" alongside "${filename}_crop.pdf"
mv -v "${filename}.toc" "$final_toc"

# 5. Run the update (it now successfully finds "${filename}_crop.toc")
editToc.sh update "$final_pdf"

# 6. Clean up the original intermediate files you no longer need
rm -fv "$cropped_file" "$final_toc"

echo "Process complete! Generated $final_pdf and $final_toc"
