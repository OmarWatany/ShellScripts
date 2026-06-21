#!/usr/bin/python
import regex
import argparse
import statistics
import sys
import fitz  # PyMuPDF
import re


def between(n, rng):
    return rng[0] <= n and n <= rng[1]


def main():
    parser = argparse.ArgumentParser(
        description="Scale PDF pages to a uniform width and height using PyMuPDF, adding white space at the bottom."
    )
    parser.add_argument("input_file", help="Path to the input cropped PDF file")
    parser.add_argument(
        "output_file", help="Path where the uniform PDF should be saved"
    )
    parser.add_argument(
        "-p", "--pages", help="pages to unifiy height only 'start-last' supported"
    )

    args = parser.parse_args()
    page_range = float("-inf"), float("inf")
    if args.pages is not None and args.pages != "":
        valid = r"\d+-\d?"
        if not re.match(valid, args.pages):
            print(f"Error page format isn't supported only \\d*-\\d*", file=sys.stderr)
            sys.exit(1)
        pages = args.pages.split("-")
        page_range = int(pages[0]), int(pages[1]) if pages[1] != "" else float("inf")

    try:
        doc = fitz.open(args.input_file)
    except Exception as e:
        print(f"Error opening input file: {e}", file=sys.stderr)
        sys.exit(1)

    if len(doc) == 0:
        print("Error: The PDF has no pages.", file=sys.stderr)
        sys.exit(1)

        # 1. Calculate target width and target height
    all_widths = [page.rect.width for page in doc if page.rect.width >= 72]
    target_width = statistics.median(all_widths) if all_widths else 595.0

    # Calculate what the scaled heights would be to find the maximum scaled height
    scaled_heights = []
    for page in doc:
        current_width = max(page.rect.width, 72)
        current_height = page.rect.height if page.rect.height > 0 else 72
        scale_factor = target_width / current_width
        scaled_heights.append(current_height * scale_factor)

    target_height = (
        statistics.quantiles(scaled_heights, n=20)[18] if scaled_heights else 842.0
    )

    print(
        f"Analyzing pages... Target width: {target_width:.2f} points | Uniform height: {target_height:.2f} points."
    )

    # 2. Create a new document for the uniform pages
    out_doc = fitz.open()

    pageIdx = 1
    for page in doc:
        current_width = max(page.rect.width, 72)
        current_height = page.rect.height if page.rect.height > 0 else 72

        scale_factor = target_width / current_width
        scaled_page_height = current_height * scale_factor

        # Create a new blank page with the uniform maximum dimensions
        new_page = out_doc.new_page(
            width=target_width,
            height=target_height
            if target_height > scaled_page_height and between(pageIdx, page_range)
            else scaled_page_height,
        )

        # Place the scaled content at the top of the new page.
        # This naturally leaves extra white space at the bottom.
        placement_rect = fitz.Rect(0, 0, target_width, scaled_page_height)
        new_page.show_pdf_page(placement_rect, doc, page.number)
        pageIdx += 1

    # 3. Save the output file
    try:
        out_doc.save(args.output_file, garbage=3, deflate=True)
        out_doc.close()
        doc.close()
        print(f"Success! Uniformly scaled PDF saved to: {args.output_file}")
    except Exception as e:
        print(f"Error saving output file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
