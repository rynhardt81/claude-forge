# PDF Tools Quick Reference

Quick reference for selecting the right PDF tool for each task.

---

## Tool Selection Matrix

### By Task

| Task | Python | JavaScript | CLI | Notes |
|------|--------|------------|-----|-------|
| **Extract text** | pdfplumber | - | pdftotext | pdfplumber preserves layout |
| **Extract tables** | pdfplumber, camelot | - | - | camelot for complex tables |
| **Merge PDFs** | pypdf | pdf-lib | qpdf | All equally capable |
| **Split PDFs** | pypdf | pdf-lib | qpdf | All equally capable |
| **Rotate pages** | pypdf | pdf-lib | qpdf | All equally capable |
| **Create PDF** | reportlab, fpdf2 | PDFKit | - | reportlab for complex layouts |
| **Fill forms** | pypdf, PyPDFForm | pdf-lib | - | See [FORMS.md](FORMS.md) |
| **Create forms** | reportlab | pdf-lib | - | pdf-lib simpler API |
| **OCR** | pytesseract | - | tesseract | Requires image conversion |
| **HTML to PDF** | WeasyPrint | Puppeteer | wkhtmltopdf | Puppeteer for JS-heavy pages |
| **Encrypt** | pypdf | - | qpdf | - |
| **Decrypt** | pypdf | - | qpdf | - |
| **Watermark** | pypdf | pdf-lib | - | - |
| **Extract images** | - | - | pdfimages | Part of poppler-utils |
| **Compress** | - | - | qpdf, gs | gs = Ghostscript |

### By Use Case

| Use Case | Recommended | Alternative |
|----------|-------------|-------------|
| **Simple text extraction** | pdfplumber | pypdf |
| **Data extraction (tables)** | pdfplumber | camelot-py |
| **Batch PDF processing** | pypdf + CLI | qpdf scripts |
| **Web app (Python)** | pypdf, WeasyPrint | reportlab |
| **Web app (Node.js)** | pdf-lib | PDFKit |
| **Browser-based** | pdf-lib | PDF.js (viewing) |
| **Report generation** | reportlab | fpdf2 |
| **Invoice/receipt** | WeasyPrint | reportlab |
| **Scanned documents** | pytesseract | - |
| **Form automation** | pypdf | PyPDFForm |

---

## Python Libraries

### pypdf

**Install:** `pip install pypdf`

**Best for:** Merging, splitting, rotating, forms, encryption

```python
from pypdf import PdfReader, PdfWriter
```

| Pros | Cons |
|------|------|
| Pure Python, no dependencies | Cannot create PDFs from scratch |
| Fast for manipulation | Text extraction less accurate than pdfplumber |
| Good form support | - |

### pdfplumber

**Install:** `pip install pdfplumber`

**Best for:** Text extraction, table extraction

```python
import pdfplumber
```

| Pros | Cons |
|------|------|
| Excellent text extraction | Slower than pypdf |
| Best table extraction | Cannot modify PDFs |
| Layout-aware | - |

### reportlab

**Install:** `pip install reportlab`

**Best for:** Creating complex PDFs, reports, graphics

```python
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate
```

| Pros | Cons |
|------|------|
| Full PDF creation | Steeper learning curve |
| Professional output | Cannot edit existing PDFs |
| Charts, graphics support | - |

### fpdf2

**Install:** `pip install fpdf2`

**Best for:** Simple PDF creation

```python
from fpdf import FPDF
```

| Pros | Cons |
|------|------|
| Simple API | Limited features |
| Lightweight | No table extraction |
| Easy to learn | - |

### PyPDFForm

**Install:** `pip install PyPDFForm`

**Best for:** Form filling with simple API

```python
from PyPDFForm import PdfWrapper
```

| Pros | Cons |
|------|------|
| Dictionary-based filling | Less flexible than pypdf |
| Simple API | Newer, smaller community |
| Can create form fields | - |

### camelot-py

**Install:** `pip install camelot-py[cv]`

**Best for:** Complex table extraction

```python
import camelot
```

| Pros | Cons |
|------|------|
| Handles complex tables | Requires OpenCV |
| Multiple extraction methods | Heavier dependencies |
| Export to DataFrame | - |

### WeasyPrint

**Install:** `pip install weasyprint`

**Best for:** HTML/CSS to PDF conversion

```python
from weasyprint import HTML
```

| Pros | Cons |
|------|------|
| CSS support | System dependencies |
| Clean output | No JavaScript rendering |
| Page size control | - |

### pytesseract

**Install:** `pip install pytesseract pdf2image`

**Best for:** OCR on scanned PDFs

```python
import pytesseract
from pdf2image import convert_from_path
```

| Pros | Cons |
|------|------|
| Free OCR | Requires Tesseract install |
| Multiple languages | Quality varies |
| Widely used | - |

---

## JavaScript Libraries

### pdf-lib

**Install:** `npm install pdf-lib`

**Best for:** PDF manipulation in any JS environment

```javascript
const { PDFDocument } = require('pdf-lib');
```

| Pros | Cons |
|------|------|
| Works everywhere (browser, Node, Deno) | No text extraction |
| Pure JavaScript | Cannot read form values |
| Good form support | - |

### PDFKit

**Install:** `npm install pdfkit`

**Best for:** Creating PDFs from scratch in Node.js

```javascript
const PDFDocument = require('pdfkit');
```

| Pros | Cons |
|------|------|
| Streaming output | Node.js only |
| Rich API | Cannot edit existing PDFs |
| Good for reports | - |

### PDF.js

**Install:** `npm install pdfjs-dist`

**Best for:** Displaying PDFs in browsers

| Pros | Cons |
|------|------|
| Official Mozilla library | Viewing only |
| Excellent rendering | Cannot modify PDFs |
| Widely used | - |

---

## Command-Line Tools

### qpdf

**Install:**
- Ubuntu: `apt install qpdf`
- macOS: `brew install qpdf`
- Windows: Download from [qpdf.sourceforge.io](https://qpdf.sourceforge.io/)

**Best for:** Merging, splitting, encryption, repair

```bash
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf
```

### pdftotext

**Install:** Part of poppler-utils
- Ubuntu: `apt install poppler-utils`
- macOS: `brew install poppler`
- Windows: Download from poppler releases

**Best for:** Quick text extraction

```bash
pdftotext -layout input.pdf output.txt
```

### pdftk

**Install:**
- Ubuntu: `apt install pdftk`
- macOS: `brew install pdftk-java`

**Best for:** Form filling, merging (legacy tool)

```bash
pdftk form.pdf fill_form data.fdf output filled.pdf
```

### Ghostscript (gs)

**Install:**
- Ubuntu: `apt install ghostscript`
- macOS: `brew install ghostscript`

**Best for:** Compression, format conversion

```bash
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=compressed.pdf input.pdf
```

### tesseract

**Install:**
- Ubuntu: `apt install tesseract-ocr`
- macOS: `brew install tesseract`

**Best for:** OCR from command line

```bash
tesseract image.png output -l eng pdf
```

---

## Installation Quick Reference

### Python (all at once)

```bash
pip install pypdf pdfplumber reportlab fpdf2 PyPDFForm weasyprint pytesseract pdf2image
```

### Node.js (all at once)

```bash
npm install pdf-lib pdfkit pdfjs-dist
```

### System tools (Ubuntu)

```bash
apt install qpdf poppler-utils tesseract-ocr ghostscript pdftk
```

### System tools (macOS)

```bash
brew install qpdf poppler tesseract ghostscript pdftk-java
```

---

## Decision Flowchart

```
What do you need to do?
│
├── Extract text/tables?
│   └── Use pdfplumber (Python) or pdftotext (CLI)
│
├── Create PDF from scratch?
│   ├── Complex layout? → reportlab
│   ├── Simple PDF? → fpdf2
│   └── From HTML? → WeasyPrint or Puppeteer
│
├── Modify existing PDF?
│   ├── Merge/split/rotate? → pypdf or qpdf
│   ├── Fill forms? → pypdf or pdf-lib
│   └── Add content? → pypdf or pdf-lib
│
├── OCR scanned PDF?
│   └── pytesseract + pdf2image
│
├── Browser-based?
│   ├── Modify PDFs? → pdf-lib
│   └── Display PDFs? → PDF.js
│
└── Compress PDF?
    └── Ghostscript or qpdf
```
