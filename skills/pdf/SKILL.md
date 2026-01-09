---
name: pdf
description: Orchestrates PDF processing tasks including text extraction, form filling, merging, splitting, and creation. Detects PDF type and recommends appropriate tools. Use for any PDF manipulation task.
---

# PDF Processing Skill

## Invocation

User runs: `/pdf <command> [arguments]`

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `extract` | Extract text or tables from PDF | `/pdf extract report.pdf` |
| `merge` | Merge multiple PDFs into one | `/pdf merge doc1.pdf doc2.pdf` |
| `split` | Split PDF into individual pages | `/pdf split document.pdf` |
| `fill` | Fill a PDF form | `/pdf fill form.pdf` |
| `create` | Create a new PDF | `/pdf create` |
| `ocr` | OCR a scanned PDF | `/pdf ocr scanned.pdf` |
| `info` | Show PDF metadata and structure | `/pdf info document.pdf` |

## Step 1: Analyze

1. Detect PDF type:
   - **Text-based** - Extractable text content
   - **Form** - Contains fillable AcroForm fields
   - **Scanned** - Image-based, requires OCR
   - **Mixed** - Combination of above

2. Present analysis:
   - "**File:** [filename]"
   - "**Pages:** [count]"
   - "**Type:** [detected type]"
   - "**Recommended tool:** [library]"

## Step 2: Recommend Tool

Based on detected type and command, recommend the appropriate tool.

| Task | Python | JavaScript | CLI |
|------|--------|------------|-----|
| Extract text | pdfplumber | - | pdftotext |
| Extract tables | pdfplumber | - | - |
| Merge/split | pypdf | pdf-lib | qpdf |
| Create PDF | reportlab | PDFKit | - |
| Fill forms | pypdf | pdf-lib | - |
| OCR | pytesseract | - | tesseract |

See [TOOLS.md](TOOLS.md) for complete reference.

## Step 3: Execute

Run the appropriate operation. See command-specific sections below.

## Step 4: Verify

1. Confirm output file was created
2. Validate page count (for merge/split)
3. Check text extraction succeeded (for extract/ocr)
4. Verify form fields were filled (for fill)

---

## Quick Start Examples

### Read a PDF

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

# Extract text
text = ""
for page in reader.pages:
    text += page.extract_text()
```

### Merge PDFs

```python
from pypdf import PdfWriter, PdfReader

writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as output:
    writer.write(output)
```

### Split PDF

```python
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as output:
        writer.write(output)
```

### Extract Metadata

```python
reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

### Rotate Pages

```python
reader = PdfReader("input.pdf")
writer = PdfWriter()

page = reader.pages[0]
page.rotate(90)  # Rotate 90 degrees clockwise
writer.add_page(page)

with open("rotated.pdf", "wb") as output:
    writer.write(output)
```

---

## Text and Table Extraction

### pdfplumber - Extract Text with Layout

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

### pdfplumber - Extract Tables

```python
with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

### Advanced Table Extraction to Excel

```python
import pandas as pd
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

---

## PDF Creation

### reportlab - Basic PDF

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter

c.drawString(100, height - 100, "Hello World!")
c.drawString(100, height - 120, "This is a PDF created with reportlab")
c.line(100, height - 140, 400, height - 140)
c.save()
```

### reportlab - Multi-Page Document

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

title = Paragraph("Report Title", styles['Title'])
story.append(title)
story.append(Spacer(1, 12))

body = Paragraph("This is the body of the report. " * 20, styles['Normal'])
story.append(body)
story.append(PageBreak())

story.append(Paragraph("Page 2", styles['Heading1']))
story.append(Paragraph("Content for page 2", styles['Normal']))

doc.build(story)
```

---

## Command-Line Tools

### pdftotext (poppler-utils)

```bash
# Extract text
pdftotext input.pdf output.txt

# Extract text preserving layout
pdftotext -layout input.pdf output.txt

# Extract specific pages
pdftotext -f 1 -l 5 input.pdf output.txt
```

### qpdf

```bash
# Merge PDFs
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# Split pages
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf --pages . 6-10 -- pages6-10.pdf

# Rotate pages
qpdf input.pdf output.pdf --rotate=+90:1

# Remove password
qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf
```

### pdftk

```bash
# Merge
pdftk file1.pdf file2.pdf cat output merged.pdf

# Split
pdftk input.pdf burst

# Rotate
pdftk input.pdf rotate 1east output rotated.pdf
```

---

## Common Tasks

### Add Watermark

```python
from pypdf import PdfReader, PdfWriter

watermark = PdfReader("watermark.pdf").pages[0]
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

### Extract Images

```bash
# Using pdfimages (poppler-utils)
pdfimages -j input.pdf output_prefix
```

### Password Protection

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

writer.encrypt("userpassword", "ownerpassword")

with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

---

## Related Guides

| Guide | Description |
|-------|-------------|
| [FORMS.md](FORMS.md) | PDF form filling with pypdf, PyPDFForm, and pdf-lib |
| [REFERENCE.md](REFERENCE.md) | Advanced features, JavaScript libraries, optimization |
| [TOOLS.md](TOOLS.md) | Complete tool selection reference |
| [OCR.md](OCR.md) | Handling scanned PDFs with OCR |

---

## Key Rules

1. Always detect PDF type before recommending approach
2. For forms, check if fillable before attempting fill
3. For scanned PDFs, warn about OCR requirements
4. Recommend Python tools by default, JS when in Node.js context
5. Always validate output file was created successfully
6. Use `auto_regenerate=False` when filling forms
7. Never skip verification step
