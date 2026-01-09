# Browser Automation MCP Server

Browser automation using Playwright for end-to-end testing of implemented features.

---

## Overview

This MCP server provides browser automation capabilities for:
- **Standard Testing Mode**: Full E2E testing with browser verification
- **Hybrid Testing Mode**: Browser testing for critical features only
- **Regression Testing**: Re-running tests on previously passing features

**Note:** This server is NOT needed for YOLO mode, which only uses lint/type-check.

---

## Quick Start

### Option 1: Use Official Playwright MCP (Recommended)

The recommended approach is to use the official Playwright MCP server:

```bash
# Install Playwright MCP
npm install -g @anthropic/playwright-mcp

# Install browsers
npx playwright install chromium
```

**Claude Desktop Configuration:**

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic/playwright-mcp"]
    }
  }
}
```

### Option 2: Custom Playwright Setup

For more control, you can set up a custom Playwright server.

---

## Playwright MCP Tools

The Playwright MCP provides these tools:

| Tool | Description |
|------|-------------|
| `navigate` | Navigate to a URL |
| `click` | Click an element |
| `type` | Type text into an input |
| `screenshot` | Take a screenshot |
| `get_text` | Get text content from element |
| `wait_for_selector` | Wait for element to appear |
| `evaluate` | Execute JavaScript |

---

## Integration with Feature Testing

### Standard Mode Workflow

```
1. @quality-engineer receives feature
2. Read feature.steps from database
3. Execute steps using Playwright tools:
   - navigate to URL
   - interact with elements
   - verify expected outcomes
4. Take screenshot as evidence
5. Mark feature as passing/failing
```

### Example Feature Test

**Feature:**
```json
{
  "name": "User login",
  "steps": [
    "Navigate to /login",
    "Enter 'test@example.com' in email field",
    "Enter 'password123' in password field",
    "Click the 'Sign In' button",
    "Verify redirect to /dashboard",
    "Verify welcome message contains username"
  ]
}
```

**Playwright Execution:**
```javascript
// Step 1
await page.goto('http://localhost:3000/login');

// Step 2
await page.fill('[name="email"]', 'test@example.com');

// Step 3
await page.fill('[name="password"]', 'password123');

// Step 4
await page.click('button[type="submit"]');

// Step 5
await page.waitForURL('**/dashboard');

// Step 6
const welcome = await page.textContent('.welcome-message');
expect(welcome).toContain('test@example.com');

// Screenshot
await page.screenshot({ path: 'login-test.png' });
```

---

## Testing Modes

### Standard Mode
- All features tested with browser automation
- Regression tests before each new feature
- Screenshots saved for each test
- ~5-10 minutes per feature

### Hybrid Mode
Browser tests only for critical categories:

| Category | Test Type | Reason |
|----------|-----------|--------|
| A (Security) | Browser | Auth must work correctly |
| C (Data) | Browser | Data integrity critical |
| D (Workflow) | Browser | Multi-step flows need verification |
| P (Payment) | Browser | Financial operations |
| B, E-O, Q-T | Lint only | Lower risk, faster |

### YOLO Mode
- No browser automation
- Lint + type-check only
- ~1-2 minutes per feature
- For prototyping only

---

## Setup Instructions

### Prerequisites

1. **Node.js 18+**
   ```bash
   node --version  # Should be 18.0.0 or higher
   ```

2. **Playwright Browsers**
   ```bash
   npx playwright install chromium
   # Or install all browsers:
   npx playwright install
   ```

### Verify Installation

```bash
# Test Playwright is working
npx playwright test --version

# Run a simple test
npx playwright test --help
```

---

## Configuration

### Environment Variables

```bash
# Base URL for testing (required)
export TEST_BASE_URL="http://localhost:3000"

# Headless mode (default: true)
export PLAYWRIGHT_HEADLESS="true"

# Slow motion for debugging (ms, default: 0)
export PLAYWRIGHT_SLOW_MO="0"

# Screenshot directory
export SCREENSHOT_DIR=".claude/features/screenshots"
```

### Playwright Config (Optional)

Create `playwright.config.ts` in your project:

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './.claude/tests',
  timeout: 30000,
  use: {
    baseURL: process.env.TEST_BASE_URL || 'http://localhost:3000',
    headless: true,
    screenshot: 'on',
    trace: 'retain-on-failure',
  },
});
```

---

## Troubleshooting

### "Browser not found"

Install browsers:
```bash
npx playwright install chromium
```

### "Connection refused"

Ensure your dev server is running:
```bash
# Start your app's dev server
npm run dev

# Then run tests
```

### Tests timeout

Increase timeout in config or check:
- Dev server is responding
- Selectors are correct
- No blocking modals/popups

### Headless mode issues

Try running with head for debugging:
```bash
export PLAYWRIGHT_HEADLESS=false
```

### Permission denied on Linux

```bash
# Install system dependencies
npx playwright install-deps
```

---

## Best Practices

### Writing Testable Features

1. **Use specific selectors**
   ```
   Good: "Click button with text 'Submit'"
   Bad: "Click the button"
   ```

2. **Include wait conditions**
   ```
   Good: "Wait for success message to appear"
   Bad: "Check if it worked"
   ```

3. **Verify visible outcomes**
   ```
   Good: "Verify cart badge shows '3'"
   Bad: "Verify item was added"
   ```

### Selector Priority

1. `data-testid` attributes (most reliable)
2. `aria-label` for accessibility
3. Text content for buttons/links
4. CSS classes (less reliable)
5. XPath (last resort)

### Handling Dynamic Content

- Use `waitForSelector` before interactions
- Use `waitForLoadState('networkidle')` for API calls
- Add explicit waits for animations

---

## Integration with CI/CD

```yaml
# GitHub Actions example
jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright
        run: npx playwright install --with-deps chromium
      - name: Start dev server
        run: npm run dev &
      - name: Wait for server
        run: npx wait-on http://localhost:3000
      - name: Run tests
        run: npx playwright test
```

---

## References

- [Playwright Documentation](https://playwright.dev/)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Testing Best Practices](https://playwright.dev/docs/best-practices)
