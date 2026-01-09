# Feature Categories

The 20 standard categories for organizing features during project initialization. Each feature should be assigned to exactly ONE category.

---

## Category Definitions

### A. Security & Access Control
**Purpose:** Authentication, authorization, permissions, data protection

**Examples:**
- User can register with email/password
- User can login with OAuth (Google, GitHub)
- Admin can manage user roles and permissions
- User session expires after 30 minutes of inactivity
- Password reset via email works correctly
- Two-factor authentication required for admin accounts
- API endpoints require valid JWT tokens
- User data is encrypted at rest

**Test Type:** Browser + API
**Priority:** HIGH (implement early)
**Typical Count:** 10-25% of total features

---

### B. Navigation Integrity
**Purpose:** Routing, links, breadcrumbs, page transitions

**Examples:**
- User can navigate from homepage to product page
- Clicking logo returns to homepage
- Back button maintains scroll position
- 404 page displays for invalid routes
- Breadcrumbs show current location
- Deep links work correctly
- Tab navigation follows logical order
- Loading states display during navigation

**Test Type:** Browser
**Priority:** HIGH (foundation for other features)
**Typical Count:** 8-15% of total features

---

### C. Real Data Verification
**Purpose:** CRUD operations, data persistence, data accuracy

**Examples:**
- User can create a new blog post
- User can edit existing blog post
- User can delete blog post with confirmation
- Deleted posts don't appear in list
- Post data persists after page refresh
- Draft posts save automatically
- Published date is accurate
- Author attribution is correct

**Test Type:** Browser + API
**Priority:** HIGH (core functionality)
**Typical Count:** 15-25% of total features

---

### D. Workflow Completeness
**Purpose:** Multi-step processes, state transitions, wizards

**Examples:**
- User can complete checkout flow (cart → shipping → payment → confirmation)
- Onboarding wizard saves progress between steps
- Form wizard validates each step before continuing
- User can go back to previous step without losing data
- Completed workflows update user state
- Workflow abandonment is tracked
- Success confirmation displays after completion

**Test Type:** Browser
**Priority:** HIGH (critical paths)
**Typical Count:** 10-20% of total features

---

### E. Error Handling & Edge Cases
**Purpose:** Validation, error messages, graceful degradation

**Examples:**
- Invalid email shows clear error message
- API timeout displays user-friendly message
- Network error allows retry
- Required fields show validation on blur
- Duplicate entries are prevented
- Malformed data is rejected with clear feedback
- 500 errors show fallback UI
- Empty states show helpful messaging

**Test Type:** Browser + API
**Priority:** MEDIUM (implement alongside happy paths)
**Typical Count:** 10-15% of total features

---

### F. Form Input & Validation
**Purpose:** Form submission, field validation, user feedback

**Examples:**
- Email field validates format on blur
- Password field shows strength indicator
- Required fields marked with asterisk
- Form submission disabled until valid
- Success message displays after submission
- Form clears after successful submission
- Autocomplete works for address fields
- File upload shows progress indicator

**Test Type:** Browser
**Priority:** MEDIUM
**Typical Count:** 8-12% of total features

---

### G. Search & Filter
**Purpose:** Search functionality, filtering, sorting, pagination

**Examples:**
- User can search products by keyword
- Search results highlight matched terms
- User can filter by category
- User can sort by price (low to high)
- Pagination works correctly
- Search with no results shows helpful message
- Filters are combinable (AND logic)
- Clear all filters button works

**Test Type:** Browser + API
**Priority:** MEDIUM
**Typical Count:** 5-10% of total features

---

### H. Responsive Design & Cross-Browser
**Purpose:** Mobile, tablet, desktop, browser compatibility

**Examples:**
- Homepage renders correctly on mobile (375px)
- Navigation menu collapses to hamburger on tablet
- Touch targets are at least 44x44px on mobile
- Images scale appropriately on all devices
- Text is readable without zooming
- Forms are usable on mobile
- Works in Chrome, Firefox, Safari
- No horizontal scroll on any viewport

**Test Type:** Browser (multi-viewport)
**Priority:** MEDIUM
**Typical Count:** 5-10% of total features

---

### I. Performance & Load Times
**Purpose:** Page load speed, API response times, optimization

**Examples:**
- Homepage loads in under 2 seconds
- Images are lazy loaded below fold
- API responses in under 500ms
- Large lists virtualized for performance
- Bundle size under 200KB
- Time to interactive under 3 seconds
- Database queries optimized (N+1 prevented)
- CDN used for static assets

**Test Type:** API + Browser
**Priority:** MEDIUM (optimize iteratively)
**Typical Count:** 3-8% of total features

---

### J. Integration & External Services
**Purpose:** Third-party APIs, webhooks, external systems

**Examples:**
- Stripe payment processing works end-to-end
- SendGrid sends transactional emails
- AWS S3 stores uploaded files
- Google Analytics tracks page views
- Webhook receives GitHub events
- OAuth login with Google works
- External API rate limits handled gracefully
- Retry logic for failed external calls

**Test Type:** API + Manual
**Priority:** MEDIUM (depends on feature dependencies)
**Typical Count:** 5-12% of total features

---

### K. Notifications & Alerts
**Purpose:** User notifications, system alerts, emails

**Examples:**
- User receives welcome email on signup
- Toast notification shows on successful action
- User receives push notification for new message
- Admin receives alert for system errors
- Email notifications can be disabled in settings
- Notification badge shows unread count
- Notifications are marked read on click
- Notification history persists

**Test Type:** Browser + Email
**Priority:** LOW-MEDIUM
**Typical Count:** 3-8% of total features

---

### L. User Preferences & Settings
**Purpose:** Configuration, customization, user-specific settings

**Examples:**
- User can change email address
- User can update password
- User can set notification preferences
- User can choose theme (light/dark)
- User can set language preference
- Settings persist across sessions
- Changes take effect immediately
- Default settings are sensible

**Test Type:** Browser
**Priority:** LOW-MEDIUM
**Typical Count:** 3-6% of total features

---

### M. Help & Documentation
**Purpose:** Tooltips, help text, user guides

**Examples:**
- Tooltips explain form fields
- Help icon links to relevant documentation
- Getting started guide displays for new users
- FAQ page answers common questions
- Contextual help appears in complex workflows
- Search within documentation works
- Video tutorials embedded where helpful
- Error messages link to troubleshooting docs

**Test Type:** Browser
**Priority:** LOW
**Typical Count:** 2-5% of total features

---

### N. Analytics & Tracking
**Purpose:** User behavior tracking, metrics, logs

**Examples:**
- Page views tracked in analytics
- Button clicks tracked with event names
- User journeys tracked through funnel
- Errors logged to monitoring service
- Performance metrics sent to APM
- A/B test variants assigned correctly
- Conversion events tracked
- Custom events tracked for key actions

**Test Type:** API + Manual
**Priority:** LOW
**Typical Count:** 2-5% of total features

---

### O. Accessibility & Internationalization
**Purpose:** WCAG compliance, screen readers, multi-language

**Examples:**
- All images have alt text
- Keyboard navigation works throughout site
- Focus indicators visible on all interactive elements
- ARIA labels on complex components
- Screen reader announces dynamic content
- Color contrast meets WCAG AA standards
- Content available in English and Spanish
- Date/time formats respect user locale

**Test Type:** Browser + Manual
**Priority:** MEDIUM (depends on requirements)
**Typical Count:** 3-8% of total features

---

### P. Payment & Financial Operations
**Purpose:** Payment processing, transactions, invoicing

**Examples:**
- User can purchase with credit card
- Payment confirmation displays immediately
- User receives receipt via email
- Failed payments show clear error
- Refunds process correctly
- Subscription billing works monthly
- Invoice PDF generated correctly
- Payment history displays all transactions

**Test Type:** API + Manual (sandbox)
**Priority:** HIGH (if applicable)
**Typical Count:** 5-15% of total features (if e-commerce)

---

### Q. Admin & Moderation
**Purpose:** Admin panels, content moderation, user management

**Examples:**
- Admin can view all users
- Admin can ban user account
- Admin can delete inappropriate content
- Moderator can approve pending posts
- Admin dashboard shows key metrics
- Audit log tracks admin actions
- Role-based access to admin features
- Bulk actions on multiple items

**Test Type:** Browser
**Priority:** MEDIUM
**Typical Count:** 5-10% of total features (if applicable)

---

### R. Collaboration & Sharing
**Purpose:** Multi-user features, sharing, real-time collaboration

**Examples:**
- User can share document via link
- Multiple users can edit document simultaneously
- User can invite collaborators via email
- Shared document shows who's currently viewing
- User can set permissions per collaborator
- Comments sync in real-time
- User can see document version history
- Conflicts resolved gracefully

**Test Type:** Browser (multi-user)
**Priority:** MEDIUM
**Typical Count:** 3-10% of total features (if applicable)

---

### S. Data Export & Reporting
**Purpose:** Reports, exports, data visualization

**Examples:**
- User can export data to CSV
- Admin can generate monthly report
- Charts display sales trends
- User can print formatted invoice
- Export includes all selected fields
- PDF report formatted correctly
- Data visualization updates in real-time
- Scheduled reports email on time

**Test Type:** API + Manual
**Priority:** LOW-MEDIUM
**Typical Count:** 3-6% of total features

---

### T. UI Polish & Aesthetics
**Purpose:** Visual design, animations, micro-interactions

**Examples:**
- Hover states on all buttons
- Smooth transitions between pages
- Loading skeletons while fetching data
- Success animation on form submission
- Empty states are visually appealing
- Icons consistent throughout app
- Color palette applied consistently
- Spacing follows design system

**Test Type:** Browser + Manual
**Priority:** LOW (implement last)
**Typical Count:** 3-8% of total features

---

## Category Assignment Rules

### Rule 1: One Category Per Feature
Every feature must be assigned to exactly ONE category. If a feature seems to fit multiple categories, choose the PRIMARY purpose.

**Example:**
- Feature: "User can save search filters for later use"
- Could fit: G (Search & Filter) OR L (User Preferences)
- Assign to: **G** (primary purpose is search-related)

### Rule 2: Security Takes Precedence
If a feature has ANY security implications, assign it to category A (Security), even if it has other purposes.

**Example:**
- Feature: "User can update profile picture"
- Could fit: C (Real Data) OR A (Security - file upload validation)
- Assign to: **A** (security implications of file uploads)

### Rule 3: Workflow Over Individual Actions
If a feature is part of a multi-step process, assign to category D (Workflow), not to the individual action's category.

**Example:**
- Feature: "User completes payment step in checkout"
- Could fit: P (Payment) OR D (Workflow)
- Assign to: **D** (part of checkout workflow)

### Rule 4: Balance Categories
Try to distribute features across categories. If one category has >30% of features, consider splitting some features or re-categorizing.

### Rule 5: Tech Stack Considerations
Some categories are more relevant for certain project types:

**Web Applications:**
- Heavy on: B, C, F, H
- Light on: K, M

**API Services:**
- Heavy on: A, C, J
- Light on: B, F, H, T

**E-commerce:**
- Heavy on: A, C, D, P
- Medium on: G, K

**SaaS Products:**
- Heavy on: A, C, L, Q
- Medium on: K, N, R

---

## Feature Count Guidelines

### Simple Project (50-100 features)
```
A. Security & Access Control: 8-12 features
B. Navigation Integrity: 6-10 features
C. Real Data Verification: 12-20 features
D. Workflow Completeness: 5-10 features
E. Error Handling: 5-8 features
F. Form Input & Validation: 4-8 features
G. Search & Filter: 2-5 features (if applicable)
H. Responsive Design: 3-5 features
I-T: 1-3 features each (as needed)
```

### Medium Project (100-200 features)
```
A. Security & Access Control: 15-25 features
B. Navigation Integrity: 12-20 features
C. Real Data Verification: 25-40 features
D. Workflow Completeness: 15-25 features
E. Error Handling: 12-18 features
F. Form Input & Validation: 10-15 features
G. Search & Filter: 5-10 features
H. Responsive Design: 6-10 features
I-T: 3-8 features each (as applicable)
```

### Complex Project (200-400+ features)
```
A. Security & Access Control: 30-50 features
B. Navigation Integrity: 20-35 features
C. Real Data Verification: 50-80 features
D. Workflow Completeness: 25-45 features
E. Error Handling: 20-30 features
F. Form Input & Validation: 15-25 features
G. Search & Filter: 10-18 features
H. Responsive Design: 10-18 features
I-T: 5-15 features each (as applicable)
```

---

## Examples by Project Type

### Example 1: E-commerce Platform
```
Total: 180 features

A. Security (22): Auth, payment security, data protection
B. Navigation (18): Product browsing, category pages
C. Data (35): Products, orders, inventory CRUD
D. Workflow (20): Checkout flow, order tracking
E. Errors (15): Payment failures, validation
F. Forms (12): Checkout forms, address validation
G. Search (12): Product search, filters, sorting
H. Responsive (10): Mobile checkout, responsive grid
P. Payment (20): Stripe, PayPal, refunds
Q. Admin (16): Order management, product management
```

### Example 2: SaaS Dashboard
```
Total: 150 features

A. Security (20): SSO, RBAC, API keys
C. Data (30): CRUD for main entities
D. Workflow (18): Onboarding, setup wizards
F. Forms (15): Settings, configurations
L. Preferences (10): User settings, team settings
N. Analytics (12): Usage metrics, dashboards
Q. Admin (15): User management, billing
R. Collaboration (15): Team features, sharing
S. Reports (15): Analytics exports, PDF reports
```

### Example 3: API Service
```
Total: 80 features

A. Security (20): Auth, rate limiting, API keys
C. Data (25): CRUD endpoints
E. Errors (12): Error responses, validation
I. Performance (8): Caching, optimization
J. Integration (15): Webhooks, third-party APIs
```

---

## Notes

- Categories are mutually exclusive but features can have dependencies across categories
- Prioritize categories A, B, C, D first (foundation)
- Categories can be customized for specific project types
- Some categories may have 0 features if not applicable to project
- Use category distribution to identify project complexity and scope
