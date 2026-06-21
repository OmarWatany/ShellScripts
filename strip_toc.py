#!/usr/bin/python

import sys
import fitz  # PyMuPDF

if len(sys.argv) < 2:
    print("Usage: python strip_toc.py <filename>")
    sys.exit(1)

pdf_path = sys.argv[1]

doc = fitz.open(pdf_path)
# This completely destroys the internal PDF outline hierarchy structure
doc.set_toc([])
doc.save(pdf_path, incremental=True, encryption=fitz.PDF_ENCRYPT_KEEP)
doc.close()
print(f"Successfully deleted TOC structure from {pdf_path}")
