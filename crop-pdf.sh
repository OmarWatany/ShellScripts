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

# 2. Run the cropping tool (outputs ${filename}_cropped.pdf)
# pdfcropmargins -ch -t 100 -pg "$2" "$input_file"
pdfcropmargins -ch -pg "$2" "$input_file"

# 3. Scale it to uniform width (outputs ${filename}_crop.pdf)
pdfuniw.py "$cropped_file" "$final_pdf" -p "$2"

# 5. Run the update (In-Place)
pdfunim.py "$input_file" "$final_pdf"

# 6. Clean up the original intermediate files you no longer need
rm -fv "$cropped_file"

echo "Process complete! Generated $final_pdf"
