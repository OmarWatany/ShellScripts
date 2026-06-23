#!/usr/bin/python
import argparse
import sys
import fitz  # PyMuPDF


def main():
    parser = argparse.ArgumentParser(
        description="Copy PDF metadata and outline in-place"
    )
    parser.add_argument("input_file", help="Path to copy MetaData FROM")
    parser.add_argument(
        "output_file", help="Path to copy MetaData TO (Modified in-place)"
    )

    args = parser.parse_args()

    # 1. Open the source document (where metadata comes from)
    try:
        doc = fitz.open(args.input_file)
    except Exception as e:
        print(f"Error opening input file: {e}", file=sys.stderr)
        sys.exit(1)

    # 2. Open the target document (the one that will be modified)
    try:
        out_doc = fitz.open(args.output_file)
    except Exception as e:
        print(f"Error opening output file: {e}", file=sys.stderr)
        doc.close()
        sys.exit(1)

    if len(out_doc) == 0:
        print("Error: The target PDF has no pages to modify.", file=sys.stderr)
        doc.close()
        out_doc.close()
        sys.exit(1)

    # 3. Copy Metadata and Table of Contents
    try:
        # Copy original Metadata
        out_doc.set_metadata(doc.metadata)

        # Copy original Outline / Table of Contents
        toc = doc.get_toc()
        if toc:
            out_doc.set_toc(toc)

        print("Metadata and Outline mapped successfully.")
    except Exception as meta_err:
        print(f"Warning: Failed to clone metadata/outline: {meta_err}", file=sys.stderr)

    # 4. Save the changes back into the output file directly
    try:
        # saveIncr() pushes the changes into the existing file without rewriting it from scratch
        out_doc.saveIncr()

        out_doc.close()
        doc.close()
        print(f"Success! Metadata updated in-place for: {args.output_file}")
    except Exception as e:
        print(f"Error saving changes in-place: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
