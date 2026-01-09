# PDF Advanced Reference

This guide covers advanced PDF features, the JavaScript ecosystem, and performance optimization.

---

## Advanced pypdf Features

### Encryption and Decryption

```python
from pypdf import PdfReader, PdfWriter

# Decrypt a PDF
reader = PdfReader("encrypted.pdf")
if reader.is_encrypted:
    reader.decrypt("password")

# Re-encrypt with new password
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)

# user_password: required to open
# owner_password: required to edit/print
writer.encrypt(
    user_password="viewonly",
    owner_password="admin123",
    permissions_flag=0b0100,  # Print only
)

with open("re-encrypted.pdf", "wb") as f:
    writer.write(f)
```

### Permission Flags

| Flag | Binary | Permission |
|------|--------|------------|
| Print | `0b0100` | Allow printing |
| Modify | `0b1000` | Allow modifications |
| Copy | `0b10000` | Allow text/image copying |
| Annotate | `0b100000` | Allow annotations |

### Watermarking

```python
from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO

# Create watermark
def create_watermark(text):
    buffer = BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    c.setFont("Helvetica", 60)
    c.setFillGray(0.5, 0.5)  # Gray with 50% opacity
    c.rotate(45)
    c.drawString(200, 100, text)
    c.save()
    buffer.seek(0)
    return PdfReader(buffer).pages[0]

# Apply watermark
watermark = create_watermark("CONFIDENTIAL")
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as f:
    writer.write(f)
```

### Metadata Manipulation

```python
from pypdf import PdfReader, PdfWriter
from datetime import datetime

reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

# Set metadata
writer.add_metadata({
    "/Title": "My Document",
    "/Author": "John Doe",
    "/Subject": "Report",
    "/Keywords": "python, pdf, automation",
    "/Creator": "My Application",
    "/Producer": "pypdf",
    "/CreationDate": f"D:{datetime.now().strftime('%Y%m%d%H%M%S')}",
})

with open("with_metadata.pdf", "wb") as f:
    writer.write(f)
```

### Page Transformations

```python
from pypdf import PdfReader, PdfWriter, Transformation

reader = PdfReader("document.pdf")
writer = PdfWriter()
page = reader.pages[0]

# Scale page
op = Transformation().scale(sx=0.5, sy=0.5)
page.add_transformation(op)

# Translate (move) page content
op = Transformation().translate(tx=100, ty=100)
page.add_transformation(op)

# Combine transformations
op = Transformation().rotate(45).scale(0.8).translate(50, 50)
page.add_transformation(op)

writer.add_page(page)
with open("transformed.pdf", "wb") as f:
    writer.write(f)
```

### Cropping Pages

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
writer = PdfWriter()

page = reader.pages[0]

# Get current dimensions
media_box = page.mediabox
print(f"Original: {media_box.width} x {media_box.height}")

# Crop (set new boundaries)
page.mediabox.lower_left = (50, 50)
page.mediabox.upper_right = (400, 600)

writer.add_page(page)
with open("cropped.pdf", "wb") as f:
    writer.write(f)
```

---

## JavaScript Libraries

### pdf-lib (Manipulation)

Best for: Modifying existing PDFs, filling forms, merging/splitting.

```javascript
const { PDFDocument, rgb, degrees } = require('pdf-lib');
const fs = require('fs');

async function modifyPdf() {
    const pdfBytes = fs.readFileSync('input.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);

    // Get pages
    const pages = pdfDoc.getPages();
    const firstPage = pages[0];

    // Draw text
    firstPage.drawText('Hello World!', {
        x: 50,
        y: 450,
        size: 30,
        color: rgb(0, 0.53, 0.71),
    });

    // Draw rectangle
    firstPage.drawRectangle({
        x: 50,
        y: 400,
        width: 200,
        height: 50,
        borderColor: rgb(1, 0, 0),
        borderWidth: 2,
    });

    // Save
    const modifiedBytes = await pdfDoc.save();
    fs.writeFileSync('modified.pdf', modifiedBytes);
}
```

### PDFKit (Generation)

Best for: Creating PDFs from scratch with complex layouts.

```javascript
const PDFDocument = require('pdfkit');
const fs = require('fs');

// Create document
const doc = new PDFDocument();
doc.pipe(fs.createWriteStream('output.pdf'));

// Add content
doc.fontSize(25).text('Hello World!', 100, 100);

doc.fontSize(12)
   .text('This is PDFKit generating a PDF.', {
       width: 400,
       align: 'justify',
   });

// Add image
doc.image('logo.png', { width: 150 });

// Add new page
doc.addPage()
   .fontSize(16)
   .text('Page 2 content');

// Finalize
doc.end();
```

### PDF.js (Viewing/Rendering)

Best for: Displaying PDFs in web browsers.

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
<canvas id="pdf-canvas"></canvas>

<script>
pdfjsLib.GlobalWorkerOptions.workerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';

async function renderPdf(url) {
    const pdf = await pdfjsLib.getDocument(url).promise;
    const page = await pdf.getPage(1);

    const scale = 1.5;
    const viewport = page.getViewport({ scale });

    const canvas = document.getElementById('pdf-canvas');
    const context = canvas.getContext('2d');
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    await page.render({
        canvasContext: context,
        viewport: viewport,
    }).promise;
}

renderPdf('document.pdf');
</script>
```

### WeasyPrint (HTML to PDF)

Best for: Converting HTML/CSS to PDF (Python).

```python
from weasyprint import HTML, CSS

# From URL
HTML('https://example.com').write_pdf('page.pdf')

# From string
html = """
<html>
<head>
    <style>
        body { font-family: Arial; margin: 2cm; }
        h1 { color: navy; }
        table { border-collapse: collapse; width: 100%; }
        td, th { border: 1px solid #ddd; padding: 8px; }
    </style>
</head>
<body>
    <h1>Report</h1>
    <p>Generated with WeasyPrint</p>
    <table>
        <tr><th>Item</th><th>Price</th></tr>
        <tr><td>Widget</td><td>$10</td></tr>
    </table>
</body>
</html>
"""
HTML(string=html).write_pdf('report.pdf')

# With custom CSS
css = CSS(string='@page { size: A4 landscape; margin: 1cm; }')
HTML(string=html).write_pdf('report.pdf', stylesheets=[css])
```

### Puppeteer (Headless Chrome)

Best for: Complex HTML to PDF with JavaScript support.

```javascript
const puppeteer = require('puppeteer');

async function htmlToPdf() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // From URL
    await page.goto('https://example.com', { waitUntil: 'networkidle0' });

    // Or from HTML
    await page.setContent(`
        <html>
        <body>
            <h1>Hello World</h1>
            <p>Generated with Puppeteer</p>
        </body>
        </html>
    `);

    await page.pdf({
        path: 'output.pdf',
        format: 'A4',
        margin: { top: '1cm', right: '1cm', bottom: '1cm', left: '1cm' },
        printBackground: true,
    });

    await browser.close();
}

htmlToPdf();
```

---

## Performance Optimization

### Incremental Writing

Process large PDFs without loading everything into memory:

```python
from pypdf import PdfReader, PdfWriter

# Process page by page
reader = PdfReader("large.pdf")
writer = PdfWriter()

for i, page in enumerate(reader.pages):
    # Process page
    writer.add_page(page)

    # Write incrementally every 100 pages
    if (i + 1) % 100 == 0:
        with open(f"output_part_{i//100}.pdf", "wb") as f:
            writer.write(f)
        writer = PdfWriter()  # Reset

# Write remaining pages
if len(writer.pages) > 0:
    with open("output_final.pdf", "wb") as f:
        writer.write(f)
```

### Image Compression

Reduce PDF size by compressing images:

```python
from PIL import Image
from io import BytesIO

def compress_image(image_bytes, quality=50):
    """Compress image for PDF embedding."""
    img = Image.open(BytesIO(image_bytes))

    # Convert to RGB if necessary
    if img.mode in ('RGBA', 'P'):
        img = img.convert('RGB')

    # Resize if too large
    max_size = (1200, 1200)
    img.thumbnail(max_size, Image.LANCZOS)

    # Compress
    buffer = BytesIO()
    img.save(buffer, format='JPEG', quality=quality, optimize=True)
    return buffer.getvalue()
```

### Chunked Processing

Process documents in batches:

```python
import os
from pypdf import PdfReader, PdfWriter

def merge_in_chunks(pdf_files, output_path, chunk_size=50):
    """Merge many PDFs in chunks to avoid memory issues."""
    temp_files = []

    for i in range(0, len(pdf_files), chunk_size):
        chunk = pdf_files[i:i + chunk_size]
        writer = PdfWriter()

        for pdf_file in chunk:
            reader = PdfReader(pdf_file)
            for page in reader.pages:
                writer.add_page(page)

        temp_path = f"temp_chunk_{i}.pdf"
        with open(temp_path, "wb") as f:
            writer.write(f)
        temp_files.append(temp_path)

    # Merge temp files
    final_writer = PdfWriter()
    for temp_file in temp_files:
        reader = PdfReader(temp_file)
        for page in reader.pages:
            final_writer.add_page(page)

    with open(output_path, "wb") as f:
        final_writer.write(f)

    # Cleanup
    for temp_file in temp_files:
        os.remove(temp_file)
```

### Caching Strategies

Cache frequently used elements:

```python
from functools import lru_cache
from pypdf import PdfReader

@lru_cache(maxsize=10)
def get_cached_reader(pdf_path):
    """Cache PDF readers to avoid re-parsing."""
    return PdfReader(pdf_path)

# For templates used repeatedly
class TemplateCache:
    def __init__(self):
        self._cache = {}

    def get_template(self, path):
        if path not in self._cache:
            self._cache[path] = PdfReader(path).pages[0]
        return self._cache[path]

template_cache = TemplateCache()
```

---

## Library Comparison

| Feature | pypdf | pdf-lib | PDFKit | reportlab |
|---------|-------|---------|--------|-----------|
| **Language** | Python | JavaScript | JavaScript | Python |
| **Merge/Split** | ✅ | ✅ | ❌ | ❌ |
| **Fill Forms** | ✅ | ✅ | ❌ | ✅ (create) |
| **Create PDF** | ❌ | ✅ | ✅ | ✅ |
| **Encrypt** | ✅ | ❌ | ❌ | ✅ |
| **Watermark** | ✅ | ✅ | ❌ | ✅ |
| **Extract Text** | ✅ | ❌ | ❌ | ❌ |
| **Browser** | ❌ | ✅ | ❌ | ❌ |
| **No Dependencies** | ✅ | ✅ | ❌ | ❌ |

---

## Best Practices Summary

1. **Choose the right tool** - See [TOOLS.md](TOOLS.md) for selection guide
2. **Process incrementally** - Don't load entire large PDFs into memory
3. **Compress images** - Resize and optimize before embedding
4. **Cache templates** - Reuse frequently accessed PDF structures
5. **Handle errors gracefully** - PDFs can be malformed or encrypted
6. **Validate output** - Always verify generated PDFs open correctly
7. **Use streaming** - For web applications, stream PDFs instead of buffering
