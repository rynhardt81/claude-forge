# OCR Guide for Scanned PDFs

This guide covers extracting text from scanned/image-based PDFs using OCR (Optical Character Recognition).

---

## Overview

Scanned PDFs contain images of text rather than actual text data. To extract content, you must:

1. **Detect** if the PDF needs OCR
2. **Convert** PDF pages to images
3. **OCR** the images to extract text
4. **Post-process** the results

---

## Detecting Scanned PDFs

Before running OCR, check if the PDF is actually image-based:

```python
from pypdf import PdfReader

def needs_ocr(pdf_path):
    """Check if PDF needs OCR (is image-based)."""
    reader = PdfReader(pdf_path)

    for page in reader.pages:
        text = page.extract_text()
        if text and text.strip():
            return False  # Has extractable text

    return True  # No extractable text = likely scanned

# Usage
if needs_ocr("document.pdf"):
    print("This PDF needs OCR")
else:
    print("This PDF has extractable text")
```

### More Thorough Detection

```python
def analyze_pdf(pdf_path):
    """Analyze PDF to determine content type."""
    reader = PdfReader(pdf_path)

    total_pages = len(reader.pages)
    pages_with_text = 0
    pages_with_images = 0

    for page in reader.pages:
        text = page.extract_text()
        if text and len(text.strip()) > 50:
            pages_with_text += 1

        if '/XObject' in page['/Resources']:
            xobject = page['/Resources']['/XObject'].get_object()
            for obj in xobject:
                if xobject[obj]['/Subtype'] == '/Image':
                    pages_with_images += 1
                    break

    return {
        "total_pages": total_pages,
        "pages_with_text": pages_with_text,
        "pages_with_images": pages_with_images,
        "needs_ocr": pages_with_text < total_pages / 2,
        "type": "scanned" if pages_with_text == 0 else
                "mixed" if pages_with_text < total_pages else
                "text-based"
    }
```

---

## Basic OCR with pytesseract

### Installation

```bash
# Python packages
pip install pytesseract pdf2image Pillow

# System dependencies
# Ubuntu/Debian
apt install tesseract-ocr poppler-utils

# macOS
brew install tesseract poppler

# Windows
# Download Tesseract: https://github.com/UB-Mannheim/tesseract/wiki
# Download Poppler: https://github.com/oschwartz10612/poppler-windows/releases
```

### Basic Usage

```python
import pytesseract
from pdf2image import convert_from_path

def ocr_pdf(pdf_path):
    """Extract text from scanned PDF using OCR."""
    # Convert PDF to images
    images = convert_from_path(pdf_path)

    # OCR each page
    text = ""
    for i, image in enumerate(images):
        page_text = pytesseract.image_to_string(image)
        text += f"\n--- Page {i + 1} ---\n"
        text += page_text

    return text

# Usage
text = ocr_pdf("scanned_document.pdf")
print(text)
```

### With Language Support

```python
# Install language pack first:
# apt install tesseract-ocr-deu  # German
# apt install tesseract-ocr-fra  # French
# apt install tesseract-ocr-jpn  # Japanese

def ocr_pdf_multilang(pdf_path, languages="eng"):
    """OCR with specific language(s)."""
    images = convert_from_path(pdf_path)

    text = ""
    for i, image in enumerate(images):
        # Multiple languages: "eng+deu+fra"
        page_text = pytesseract.image_to_string(image, lang=languages)
        text += f"\n--- Page {i + 1} ---\n"
        text += page_text

    return text

# Usage
text = ocr_pdf_multilang("german_doc.pdf", "deu")
text = ocr_pdf_multilang("mixed_doc.pdf", "eng+fra")
```

### Available Languages

| Code | Language | Code | Language |
|------|----------|------|----------|
| eng | English | chi_sim | Chinese (Simplified) |
| deu | German | chi_tra | Chinese (Traditional) |
| fra | French | jpn | Japanese |
| spa | Spanish | kor | Korean |
| ita | Italian | ara | Arabic |
| por | Portuguese | rus | Russian |

List all installed: `tesseract --list-langs`

---

## Image Preprocessing

Improve OCR accuracy with image preprocessing:

```python
from PIL import Image, ImageEnhance, ImageFilter
import pytesseract
from pdf2image import convert_from_path

def preprocess_image(image):
    """Preprocess image for better OCR results."""
    # Convert to grayscale
    image = image.convert('L')

    # Increase contrast
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(2.0)

    # Sharpen
    image = image.filter(ImageFilter.SHARPEN)

    # Binarize (black and white)
    threshold = 150
    image = image.point(lambda p: 255 if p > threshold else 0)

    return image

def ocr_with_preprocessing(pdf_path):
    """OCR with image preprocessing."""
    images = convert_from_path(pdf_path, dpi=300)  # Higher DPI

    text = ""
    for i, image in enumerate(images):
        processed = preprocess_image(image)
        page_text = pytesseract.image_to_string(processed)
        text += f"\n--- Page {i + 1} ---\n"
        text += page_text

    return text
```

### DPI Settings

| DPI | Quality | Speed | Use Case |
|-----|---------|-------|----------|
| 150 | Low | Fast | Quick preview |
| 200 | Medium | Medium | Standard documents |
| 300 | Good | Slow | Best balance |
| 400+ | High | Very slow | Small text, poor scans |

```python
# Adjust DPI based on content
images = convert_from_path(pdf_path, dpi=300)  # High quality
images = convert_from_path(pdf_path, dpi=150)  # Fast processing
```

---

## Advanced OCR Configuration

### Page Segmentation Modes

```python
# PSM modes for pytesseract
# 0  = Orientation and script detection only
# 1  = Automatic with OSD
# 3  = Fully automatic (default)
# 4  = Single column of text
# 6  = Single block of text
# 7  = Single line
# 8  = Single word
# 11 = Sparse text
# 13 = Raw line

custom_config = r'--psm 6 --oem 3'
text = pytesseract.image_to_string(image, config=custom_config)
```

### OCR Engine Modes

```python
# OEM modes
# 0 = Legacy engine only
# 1 = Neural nets LSTM only
# 2 = Legacy + LSTM
# 3 = Default (based on availability)

custom_config = r'--oem 1'  # Use LSTM (neural net)
text = pytesseract.image_to_string(image, config=custom_config)
```

### Character Whitelist

```python
# Only recognize certain characters
custom_config = r'-c tessedit_char_whitelist=0123456789'
text = pytesseract.image_to_string(image, config=custom_config)

# Numbers and common symbols
custom_config = r'-c tessedit_char_whitelist=0123456789.-$%'
```

---

## Output Formats

### Get Structured Data

```python
# Get word-level data with bounding boxes
data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)

for i, word in enumerate(data['text']):
    if word.strip():
        print(f"Word: {word}")
        print(f"  Position: ({data['left'][i]}, {data['top'][i]})")
        print(f"  Size: {data['width'][i]}x{data['height'][i]}")
        print(f"  Confidence: {data['conf'][i]}%")
```

### Generate Searchable PDF

```python
from pdf2image import convert_from_path
import pytesseract

def create_searchable_pdf(input_pdf, output_pdf):
    """Create searchable PDF from scanned PDF."""
    images = convert_from_path(input_pdf, dpi=300)

    pdf_pages = []
    for image in images:
        # Generate PDF with hidden text layer
        pdf = pytesseract.image_to_pdf_or_hocr(image, extension='pdf')
        pdf_pages.append(pdf)

    # Combine pages
    from pypdf import PdfReader, PdfWriter
    from io import BytesIO

    writer = PdfWriter()
    for pdf_bytes in pdf_pages:
        reader = PdfReader(BytesIO(pdf_bytes))
        for page in reader.pages:
            writer.add_page(page)

    with open(output_pdf, "wb") as f:
        writer.write(f)

create_searchable_pdf("scanned.pdf", "searchable.pdf")
```

### Export to hOCR (HTML)

```python
# Get hOCR output (HTML with position data)
hocr = pytesseract.image_to_pdf_or_hocr(image, extension='hocr')

with open("output.hocr", "wb") as f:
    f.write(hocr)
```

---

## Batch Processing

### Process Multiple PDFs

```python
import os
from concurrent.futures import ProcessPoolExecutor
from pdf2image import convert_from_path
import pytesseract

def process_single_pdf(pdf_path):
    """Process a single PDF and return text."""
    try:
        images = convert_from_path(pdf_path, dpi=200)
        text = ""
        for image in images:
            text += pytesseract.image_to_string(image) + "\n"
        return pdf_path, text, None
    except Exception as e:
        return pdf_path, None, str(e)

def batch_ocr(pdf_folder, output_folder, workers=4):
    """Batch OCR all PDFs in a folder."""
    os.makedirs(output_folder, exist_ok=True)

    pdf_files = [
        os.path.join(pdf_folder, f)
        for f in os.listdir(pdf_folder)
        if f.endswith('.pdf')
    ]

    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = list(executor.map(process_single_pdf, pdf_files))

    for pdf_path, text, error in results:
        filename = os.path.basename(pdf_path).replace('.pdf', '.txt')
        output_path = os.path.join(output_folder, filename)

        if text:
            with open(output_path, 'w') as f:
                f.write(text)
            print(f"Processed: {pdf_path}")
        else:
            print(f"Failed: {pdf_path} - {error}")

batch_ocr("scanned_pdfs/", "extracted_text/")
```

---

## Troubleshooting

### Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Empty output | Low contrast scan | Preprocess image |
| Garbage text | Wrong language | Set correct `lang` |
| Missing characters | Font not recognized | Train Tesseract or use higher DPI |
| Slow processing | High DPI | Reduce DPI or use parallel processing |
| Memory errors | Large PDF | Process page by page |

### Fixing Low Quality Scans

```python
from PIL import Image, ImageEnhance, ImageFilter
import cv2
import numpy as np

def fix_low_quality_scan(image):
    """Fix common scan quality issues."""
    # Convert PIL to CV2
    cv_image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

    # Deskew
    gray = cv2.cvtColor(cv_image, cv2.COLOR_BGR2GRAY)
    coords = np.column_stack(np.where(gray > 0))
    angle = cv2.minAreaRect(coords)[-1]
    if angle < -45:
        angle = 90 + angle
    (h, w) = cv_image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    cv_image = cv2.warpAffine(cv_image, M, (w, h),
                               flags=cv2.INTER_CUBIC,
                               borderMode=cv2.BORDER_REPLICATE)

    # Denoise
    cv_image = cv2.fastNlMeansDenoisingColored(cv_image, None, 10, 10, 7, 21)

    # Convert back to PIL
    return Image.fromarray(cv2.cvtColor(cv_image, cv2.COLOR_BGR2RGB))
```

### Handling Mixed PDFs

```python
def process_mixed_pdf(pdf_path):
    """Handle PDFs with both text and scanned pages."""
    from pypdf import PdfReader
    from pdf2image import convert_from_path
    import pytesseract

    reader = PdfReader(pdf_path)
    images = convert_from_path(pdf_path, dpi=200)

    all_text = []

    for i, page in enumerate(reader.pages):
        # Try extracting text first
        text = page.extract_text()

        if text and len(text.strip()) > 50:
            # Page has extractable text
            all_text.append(f"--- Page {i + 1} (text) ---\n{text}")
        else:
            # Page needs OCR
            ocr_text = pytesseract.image_to_string(images[i])
            all_text.append(f"--- Page {i + 1} (OCR) ---\n{ocr_text}")

    return "\n\n".join(all_text)
```

---

## Quick Reference

| Task | Code |
|------|------|
| Basic OCR | `pytesseract.image_to_string(image)` |
| With language | `pytesseract.image_to_string(image, lang='deu')` |
| Get boxes | `pytesseract.image_to_boxes(image)` |
| Get data | `pytesseract.image_to_data(image)` |
| To PDF | `pytesseract.image_to_pdf_or_hocr(image, extension='pdf')` |
| To hOCR | `pytesseract.image_to_pdf_or_hocr(image, extension='hocr')` |
| PDF to images | `convert_from_path(pdf_path, dpi=300)` |
