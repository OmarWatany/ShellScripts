#!/usr/bin/python
import argparse
import sys
import fitz  # PyMuPDF
import re


def between(n, rng):
    return rng[0] <= n and n <= rng[1]


def main():
    parser = argparse.ArgumentParser(description="Cut to specified box")
    parser.add_argument("input_file", help="Path to the input cropped PDF file")
    parser.add_argument(
        "output_file", help="Path where the uniform PDF should be saved"
    )
    parser.add_argument(
        "-p", "--pages", help="pages to unifiy height only 'start-last' supported"
    )
    # Added --evo argument. Choice restricts input to '1' or '2'
    parser.add_argument(
        "--evo",
        choices=["1", "2"],
        help="Alternating trim mode. '1': even-left/odd-right, '2': odd-left/even-right",
    )

    args = parser.parse_args()
    page_range = float("-inf"), float("inf")
    if args.pages is not None and args.pages != "":
        valid = r"\d+-\d?"
        if not re.match(valid, args.pages):
            print("Error page format isn't supported only \\d*-\\d*", file=sys.stderr)
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

    # Base trim size
    base_trim = 77

    # 2. Create a new document for the uniform pages
    out_doc = fitz.open()

    page_idx = 1
    for page in doc:
        # Get the original boundaries
        orig_width = page.rect.width
        orig_height = page.rect.height

        # Initialize trims for this specific page
        current_trim_left = 0
        current_trim_right = 0

        # Determine trims based on page range and --evo flag
        if between(page_idx, page_range):
            is_even = page_idx % 2 == 0

            if args.evo == "1":
                # Mode 1: even-odd (Even -> Left trim, Odd -> Right trim)
                if is_even:
                    current_trim_left = base_trim
                else:
                    current_trim_right = base_trim
            elif args.evo == "2":
                # Mode 2: odd-even (Odd -> Left trim, Even -> Right trim)
                if not is_even:
                    current_trim_left = base_trim
                else:
                    current_trim_right = base_trim
            else:
                # Default behavior: Trim both sides
                current_trim_left = base_trim
                current_trim_right = base_trim

        # Calculate the dimensions of the new, smaller page
        new_width = orig_width - current_trim_left - current_trim_right
        new_height = orig_height

        # Prevent creating impossible/negative width pages
        if new_width <= 10:
            print(
                f"Warning: Page {page.number + 1} is too narrow to trim. Skipping trim.",
                file=sys.stderr,
                # Reset to zero to prevent crashing out_doc.new_page()
            )
            new_width = orig_width
            current_trim_left = 0
            current_trim_right = 0

        # Create a fresh, blank page with the exact target dimensions
        new_page = out_doc.new_page(width=new_width, height=new_height)

        # The bounding box where the content will be placed on our NEW page
        placement_rect = fitz.Rect(0, 0, new_width, new_height)

        # The 'clip' defines the EXACT region of the OLD page to slice out.
        clip_rect = fitz.Rect(
            current_trim_left, 0, orig_width - current_trim_right, orig_height
        )

        # Draw only the clipped area onto the new page
        new_page.show_pdf_page(placement_rect, doc, page.number, clip=clip_rect)
        page_idx += 1

    # Ensure out_doc actually has pages before saving to prevent a 'zero page' error
    if len(out_doc) == 0:
        print(
            "Error: No pages were processed. Cannot save an empty PDF.", file=sys.stderr
        )
        sys.exit(1)

    try:
        # Copy original Metadata
        out_doc.set_metadata(doc.metadata)

        # Copy original Outline / Table of Contents
        toc = doc.get_toc()
        if toc:
            out_doc.set_toc(toc)
    except Exception as meta_err:
        print(f"Warning: Failed to clone metadata/outline: {meta_err}", file=sys.stderr)

    # 3. Save the output file
    try:
        out_doc.save(args.output_file, garbage=4, deflate=True)
        out_doc.close()
        doc.close()
        print(f"Success! Destructively trimmed PDF saved to: {args.output_file}")

    except Exception as e:
        print(f"Error saving output file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
