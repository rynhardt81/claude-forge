# PDF Form Filling Guide

This guide covers filling PDF forms (AcroForms) using Python and JavaScript libraries.

---

## Overview

PDF forms use the AcroForm structure to define interactive fields. Before filling a form:

1. **Check if fillable** - Not all PDFs have form fields
2. **Identify field names** - Use `get_fields()` to list available fields
3. **Determine field types** - Text, checkbox, radio, dropdown, etc.
4. **Handle special cases** - Checkboxes need valid state values

---

## Python: pypdf

### Reading Form Fields

```python
from pypdf import PdfReader

reader = PdfReader("form.pdf")
fields = reader.get_fields()

# List all field names and values
for field_name, field_data in fields.items():
    print(f"Field: {field_name}")
    print(f"  Type: {field_data.get('/FT')}")
    print(f"  Value: {field_data.get('/V')}")
    print()
```

### Filling Text Fields

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("form.pdf")
writer = PdfWriter()

# Clone the PDF
writer.append(reader)

# Fill form fields
writer.update_page_form_field_values(
    writer.pages[0],
    {
        "name": "John Doe",
        "email": "john@example.com",
        "address": "123 Main Street",
    },
    auto_regenerate=False,  # Important: prevents "save changes" dialog
)

with open("filled_form.pdf", "wb") as output:
    writer.write(output)
```

### Handling Checkboxes

Checkboxes require specific state values. You must find the valid states first:

```python
from pypdf import PdfReader

reader = PdfReader("form.pdf")
fields = reader.get_fields()

# Find checkbox states
for field_name, field_data in fields.items():
    if field_data.get('/FT') == '/Btn':  # Button type (includes checkboxes)
        states = field_data.get('/_States_')
        current = field_data.get('/AS')
        print(f"Checkbox: {field_name}")
        print(f"  Valid states: {states}")
        print(f"  Current state: {current}")
```

Common checkbox states:
- `/Yes` and `/Off`
- `/On` and `/Off`
- `/1` and `/Off`

```python
# Fill checkbox with valid state
writer.update_page_form_field_values(
    writer.pages[0],
    {
        "agree_terms": "/Yes",      # Check the box
        "newsletter": "/Off",        # Uncheck the box
    },
    auto_regenerate=False,
)
```

### Flattening Forms

Flattening removes form fields while keeping the filled content:

```python
writer.update_page_form_field_values(
    writer.pages[0],
    {"name": "John Doe"},
    auto_regenerate=False,
    flatten=True,  # Remove form fields, keep content
)
```

### Best Practices for pypdf

| Setting | Value | Reason |
|---------|-------|--------|
| `auto_regenerate` | `False` | Prevents "save changes" dialog |
| `flatten` | `True` | When form should not be editable after |

---

## Python: PyPDFForm

PyPDFForm is a specialized library for PDF forms with a simpler API.

### Installation

```bash
pip install PyPDFForm
```

### Inspecting Form Fields

```python
from PyPDFForm import PdfWrapper

# List all fields
pdf = PdfWrapper("form.pdf")
print(pdf.schema)
```

### Filling Forms

```python
from PyPDFForm import PdfWrapper

# Fill using dictionary
filled = PdfWrapper("form.pdf").fill(
    {
        "name": "John Doe",
        "email": "john@example.com",
        "agree": True,  # Checkbox
        "country": 0,   # Dropdown (index)
    }
)

# Save
with open("filled.pdf", "wb") as output:
    output.write(filled.read())
```

### Creating Form Fields

```python
from PyPDFForm import PdfWrapper

pdf = PdfWrapper("blank.pdf")

# Add text field
pdf.create_widget(
    widget_type="text",
    name="full_name",
    page_number=1,
    x=100,
    y=700,
    width=200,
    height=20,
)

# Add checkbox
pdf.create_widget(
    widget_type="checkbox",
    name="agree",
    page_number=1,
    x=100,
    y=650,
    size=15,
)

with open("form_with_fields.pdf", "wb") as output:
    output.write(pdf.read())
```

---

## JavaScript: pdf-lib

pdf-lib works in browsers, Node.js, Deno, and React Native.

### Installation

```bash
npm install pdf-lib
```

### Reading Form Fields

```javascript
const { PDFDocument } = require('pdf-lib');
const fs = require('fs');

async function listFormFields(pdfPath) {
    const pdfBytes = fs.readFileSync(pdfPath);
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const form = pdfDoc.getForm();

    const fields = form.getFields();
    fields.forEach(field => {
        const type = field.constructor.name;
        const name = field.getName();
        console.log(`${type}: ${name}`);
    });
}

listFormFields('form.pdf');
```

### Filling Text Fields

```javascript
const { PDFDocument } = require('pdf-lib');
const fs = require('fs');

async function fillForm() {
    const pdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const form = pdfDoc.getForm();

    // Fill text fields
    form.getTextField('name').setText('John Doe');
    form.getTextField('email').setText('john@example.com');
    form.getTextField('address').setText('123 Main Street');

    // Save
    const filledPdfBytes = await pdfDoc.save();
    fs.writeFileSync('filled.pdf', filledPdfBytes);
}

fillForm();
```

### Filling Checkboxes and Radio Buttons

```javascript
async function fillCheckboxes() {
    const pdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const form = pdfDoc.getForm();

    // Checkboxes
    form.getCheckBox('agree_terms').check();
    form.getCheckBox('newsletter').uncheck();

    // Radio buttons
    form.getRadioGroup('payment_method').select('credit_card');

    const filledPdfBytes = await pdfDoc.save();
    fs.writeFileSync('filled.pdf', filledPdfBytes);
}
```

### Filling Dropdowns

```javascript
async function fillDropdown() {
    const pdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const form = pdfDoc.getForm();

    // Dropdown / Option List
    form.getDropdown('country').select('United States');
    form.getOptionList('interests').select(['Sports', 'Music']);

    const filledPdfBytes = await pdfDoc.save();
    fs.writeFileSync('filled.pdf', filledPdfBytes);
}
```

### Custom Fonts for Non-Latin Characters

The default Helvetica font only supports Latin characters. For other scripts:

```javascript
const { PDFDocument, StandardFonts } = require('pdf-lib');
const fontkit = require('@pdf-lib/fontkit');
const fs = require('fs');

async function fillWithCustomFont() {
    const pdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);

    // Register fontkit for custom fonts
    pdfDoc.registerFontkit(fontkit);

    // Embed custom font
    const fontBytes = fs.readFileSync('NotoSans-Regular.ttf');
    const customFont = await pdfDoc.embedFont(fontBytes);

    const form = pdfDoc.getForm();
    const nameField = form.getTextField('name');

    // Set font before setting text
    nameField.updateAppearances(customFont);
    nameField.setText('日本語テキスト');

    const filledPdfBytes = await pdfDoc.save();
    fs.writeFileSync('filled.pdf', filledPdfBytes);
}
```

### Flattening Forms

```javascript
async function flattenForm() {
    const pdfBytes = fs.readFileSync('form.pdf');
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const form = pdfDoc.getForm();

    // Fill fields first
    form.getTextField('name').setText('John Doe');

    // Flatten - makes form non-editable
    form.flatten();

    const flattenedPdfBytes = await pdfDoc.save();
    fs.writeFileSync('flattened.pdf', flattenedPdfBytes);
}
```

### Creating Forms

```javascript
const { PDFDocument, rgb } = require('pdf-lib');
const fs = require('fs');

async function createForm() {
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage([550, 750]);
    const form = pdfDoc.getForm();

    // Add text field
    const nameField = form.createTextField('name');
    nameField.setText('');
    nameField.addToPage(page, { x: 100, y: 650, width: 300, height: 30 });

    // Add checkbox
    const agreeBox = form.createCheckBox('agree');
    agreeBox.addToPage(page, { x: 100, y: 600, width: 20, height: 20 });

    // Add dropdown
    const countryDropdown = form.createDropdown('country');
    countryDropdown.addOptions(['USA', 'Canada', 'UK', 'Australia']);
    countryDropdown.addToPage(page, { x: 100, y: 550, width: 200, height: 30 });

    // Add radio group
    const paymentGroup = form.createRadioGroup('payment');
    paymentGroup.addOptionToPage('credit', page, { x: 100, y: 500, width: 15, height: 15 });
    paymentGroup.addOptionToPage('debit', page, { x: 100, y: 475, width: 15, height: 15 });
    paymentGroup.addOptionToPage('paypal', page, { x: 100, y: 450, width: 15, height: 15 });

    const pdfBytes = await pdfDoc.save();
    fs.writeFileSync('new_form.pdf', pdfBytes);
}

createForm();
```

---

## Troubleshooting

### Form Fields Not Visible After Filling

**Problem:** Filled values don't appear in PDF viewer.

**Solutions:**
1. Use `auto_regenerate=False` (pypdf)
2. Update appearances after setting values (pdf-lib)
3. Try flattening the form

### Checkbox Won't Check

**Problem:** Setting checkbox to "Yes" or "True" doesn't work.

**Solution:** Find valid states first:
```python
states = fields['checkbox_name'].get('/_States_')
# Use one of the returned states, e.g., '/Yes' or '/1'
```

### Non-Latin Characters Not Displaying

**Problem:** Japanese, Chinese, Arabic, etc. text appears as boxes.

**Solution:** Embed a font that supports those characters:
- Python: Use reportlab with embedded fonts
- JavaScript: Use pdf-lib with fontkit

### "Save Changes" Dialog Appears

**Problem:** PDF viewer prompts to save changes on open.

**Solution:** Set `auto_regenerate=False` when filling.

---

## Quick Reference

| Task | pypdf | PyPDFForm | pdf-lib |
|------|-------|-----------|---------|
| List fields | `reader.get_fields()` | `pdf.schema` | `form.getFields()` |
| Fill text | `update_page_form_field_values()` | `fill({...})` | `getTextField().setText()` |
| Check box | Use valid state from `/_States_` | `fill({field: True})` | `getCheckBox().check()` |
| Flatten | `flatten=True` | N/A | `form.flatten()` |
| Custom font | Use reportlab | Limited | Use fontkit |
