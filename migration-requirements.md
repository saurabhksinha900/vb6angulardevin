# VB6 to Angular 19 Migration Requirements

## 1. Overview

This document defines the requirements for migrating the VB6 Inventory Management System to Angular 19. The migration preserves all existing functionality while modernizing the technology stack with standalone components, TypeScript, SCSS, and reactive state management.

**Source:** VB6 application in `src/` folder (12 files: 5 forms, 3 modules, 3 classes, 1 project file)
**Target:** Angular 19 single-page application with dark/light theme support

---

## 2. Component Mapping (VB6 Forms → Angular Components)

| VB6 Form | Angular Component | Route | Description |
|----------|------------------|-------|-------------|
| `frmLogin.frm` | `LoginComponent` | `/login` | Authentication with 3-attempt lockout, demo credentials hint, theme toggle |
| `frmMain.frm` | `DashboardComponent` | `/dashboard` | Product table, search/filter, CRUD actions, status bar, report/about modals |
| `frmProduct.frm` | `ProductFormComponent` | `/product/:id` | Add/Edit product form with validation, SKU auto-generate for new products |
| `frmReport.frm` | `ReportComponent` | Modal on `/dashboard` | 4 report types with generate and text export |
| `frmAbout.frm` | `AboutComponent` | Modal on `/dashboard` | App info with migration note |

### Key Differences from VB6
- VB6 uses modal forms (`Show vbModal`); Angular uses route navigation and modal overlays
- frmProduct was a modal in VB6; in Angular it becomes a routed page (`/product/new`, `/product/:id`)
- frmReport and frmAbout remain modals, triggered from the dashboard
- Angular adds a theme toggle button not present in VB6

---

## 3. Service Mapping (VB6 Modules → Angular Services)

| VB6 Module | Angular Service | Purpose |
|------------|----------------|---------|
| `modDatabase.bas` | `InventoryService` | In-memory CRUD, search, filter, reporting, seed data |
| `modDatabase.bas` (auth portion) | `AuthService` | User authentication, session management, login attempt tracking |
| `modUtilities.bas` | `UtilityService` | Validation (SKU, price, quantity), currency formatting |
| `modConstants.bas` | `constants.ts` | Enums, validation ranges, category names, app metadata |
| *(new)* | `ThemeService` | Dark/light theme toggle with localStorage persistence |

### Key Differences from VB6
- VB6 `modDatabase` uses ADO/Jet 4.0 in-memory SQL; Angular uses RxJS `BehaviorSubject` with array operations
- VB6 global variables (`g_Connection`, `g_CurrentUser`) become injectable Angular services
- VB6 `HashPassword` (XOR-based) is replicated as `simpleHash()` in AuthService for demo compatibility
- VB6 logging (`LogMessage`, `LogError`) maps to `console.log`/`console.error` in Angular

---

## 4. Model Mapping (VB6 Classes → TypeScript Interfaces)

| VB6 Class | TypeScript Interface/Model | Fields |
|-----------|---------------------------|--------|
| `clsProduct.cls` | `Product` interface | `productId`, `sku`, `productName`, `description`, `category` (enum), `unitPrice`, `quantityInStock`, `reorderLevel`, `dateAdded`, `lastModified`, `isActive` |
| `clsUser.cls` | `User` interface | `userId`, `username`, `passwordHash`, `fullName`, `role` (enum), `isActive`, `loginAttempts`, `lastLoginDate` |
| `clsInventory.cls` | Absorbed into `InventoryService` | Business logic methods become service methods |

### New Fields (not in VB6)
- `Product.description` — optional text description
- `Product.dateAdded`, `Product.lastModified` — timestamps for audit
- `Product.isActive` — soft delete support
- `User.isActive` — account status
- `User.loginAttempts` — persisted attempt count
- `User.lastLoginDate` — last successful login timestamp

### Enums

| VB6 Constants | TypeScript Enum | Values |
|---------------|----------------|--------|
| `CAT_ELECTRONICS`, `CAT_CLOTHING`, etc. | `ProductCategory` | Electronics=1, Clothing=2, Food=3, Furniture=4, OfficeSupplies=5, Other=6 |
| `ROLE_ADMIN`, `ROLE_MANAGER`, `ROLE_SUPERVISOR` | `UserRole` | Admin=1, Manager=2, Clerk=3 |

### Helper Functions

| VB6 Property/Method | TypeScript Function | Description |
|---------------------|---------------------|-------------|
| `clsProduct.TotalValue` | `totalValue(product)` | Returns `unitPrice * quantityInStock` |
| `clsProduct.IsLowStock` | `isLowStock(product)` | Returns `quantityInStock <= reorderLevel` |
| `clsProduct.IsOutOfStock` | `isOutOfStock(product)` | Returns `quantityInStock === 0` |
| `clsProduct.Status` | Computed in component | Returns "OK", "Low Stock", or "Out of Stock" |
| `clsUser.CanAddProduct` | `canEditProducts(user)` | Admin or Manager |
| `clsUser.CanDeleteProduct` | `canDeleteProducts(user)` | Admin only |
| *(new)* | `canManageUsers(user)` | Admin only |
| `clsProduct.Validate()` | Reactive form validators | Angular form validation replaces manual validation |

---

## 5. Feature Parity Checklist

### 5.1 Authentication (frmLogin → LoginComponent)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | Username/password text fields | Reactive form with `FormGroup` | Required |
| 2 | Login button with validation | Form submit with validation errors | Required |
| 3 | Empty field validation ("Please enter a username/password") | Angular `Validators.required` | Required |
| 4 | 3-attempt lockout with counter display | `loginAttempts` counter in AuthService | Required |
| 5 | Lockout message and app close | Disable form and show lockout message | Required |
| 6 | Password masking (`PasswordChar = "*"`) | `<input type="password">` | Required |
| 7 | Exit button | Not needed (browser tab close) | Removed |
| 8 | *(new)* Demo credentials hint | Show hint text below form | New Feature |
| 9 | *(new)* Theme toggle on login page | Toggle button in corner | New Feature |

### 5.2 Role-Based Access Control (RBAC)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | Admin: full access (add, edit, delete) | Role check in component + route guard | Required |
| 2 | Manager: view + add + edit (no delete) | Conditional button visibility | Required |
| 3 | Supervisor/Clerk: view only (reports allowed) | Hide action buttons, allow reports | Required |
| 4 | Button enable/disable based on role | `*ngIf` / `[disabled]` bindings | Required |
| 5 | Menu enable/disable based on role | Not applicable (no menu bar in SPA) | Adapted |

### 5.3 Dashboard (frmMain → DashboardComponent)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | ListView with 9 columns (ID, SKU, Name, Category, Price, Qty, Reorder, Total Value, Status) | HTML `<table>` with all columns | Required |
| 2 | Color coding: red for out of stock, orange for low stock | CSS classes with row highlighting | Required |
| 3 | Search by product name | Text input with filter pipe/method | Required |
| 4 | Filter by category dropdown (All + 6 categories) | `<select>` dropdown | Required |
| 5 | Clear/Reset button | Reset search and filter | Required |
| 6 | Refresh button | Reload data from service | Required |
| 7 | Status bar (User, Products count, Low Stock count, Total Value) | Footer bar component | Required |
| 8 | Add/Edit/Delete buttons (RBAC-controlled) | Buttons with role-based visibility | Required |
| 9 | Report button → opens report modal | Button opens ReportComponent modal | Required |
| 10 | About menu → opens about modal | Button/link opens AboutComponent modal | Required |
| 11 | Double-click to edit product | Row click to navigate to edit | Adapted |
| 12 | Confirmation dialog for delete | Browser confirm or custom modal | Required |
| 13 | Menu bar (File, Products, Reports, Help) | Top navigation bar | Adapted |
| 14 | *(new)* Top bar with user info, theme toggle, logout | Header component | New Feature |

### 5.4 Product Form (frmProduct → ProductFormComponent)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | Add mode: all fields editable | Route `/product/new` | Required |
| 2 | Edit mode: SKU field disabled | Route `/product/:id`, SKU readonly | Required |
| 3 | SKU validation (XXX-XXXX-XXXX format) | Custom validator function | Required |
| 4 | Product name required, max 100 chars | `Validators.required`, `Validators.maxLength(100)` | Required |
| 5 | Category dropdown (6 categories) | `<select>` with enum values | Required |
| 6 | Price validation ($0.01 - $999,999.99) | Custom validator | Required |
| 7 | Quantity validation (0 - 999,999, whole numbers) | Custom validator | Required |
| 8 | Reorder level validation (0 - 999,999) | Custom validator | Required |
| 9 | Duplicate SKU check on add | Service-level validation | Required |
| 10 | Save button → validates and saves | Form submit → service call | Required |
| 11 | Cancel button → returns to dashboard | Router navigate back | Required |
| 12 | Hint labels for each field | Placeholder text or helper text | Required |
| 13 | *(new)* SKU auto-generate button | Generate random valid SKU | New Feature |

### 5.5 Reports (frmReport → ReportComponent)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | Summary Report (totals, averages, counts) | Generate formatted text | Required |
| 2 | By Category Report (grouped by category) | Generate formatted text | Required |
| 3 | Low Stock Alert Report (qty <= reorder level) | Generate formatted text | Required |
| 4 | Inventory Value Report (sorted by total value) | Generate formatted text | Required |
| 5 | Radio button selection for report type | Radio buttons or button group | Required |
| 6 | Generate button | Trigger report generation | Required |
| 7 | Report output in read-only text area (Courier New) | `<pre>` or `<textarea readonly>` with monospace font | Required |
| 8 | Export to text file | `Blob` + `URL.createObjectURL` download | Required |
| 9 | Default filename: `Report_[Type]_[Date].txt` | Same naming convention | Required |

### 5.6 About Dialog (frmAbout → AboutComponent)
| # | VB6 Feature | Angular Implementation | Status |
|---|------------|----------------------|--------|
| 1 | App name, version, description | Display from constants | Required |
| 2 | Developer name, copyright | Display from constants | Required |
| 3 | OK button to close | Close button | Required |
| 4 | *(new)* Migration note | "Migrated from VB6 to Angular 19" | New Feature |

---

## 6. Data Storage

### VB6 Approach
- ADO with Microsoft Jet 4.0 OLE DB Provider
- In-memory SQL database with `CREATE TABLE`, `INSERT`, `SELECT`, `UPDATE`, `DELETE`
- Global `g_Connection` object
- SQL string concatenation with `EscapeSQL` for safety

### Angular Approach
- RxJS `BehaviorSubject<Product[]>` in `InventoryService`
- All CRUD operations manipulate the in-memory array
- Subscribers get reactive updates via `Observable`
- No backend API; all data is in-memory (resets on page refresh)
- Same 10 seed products as VB6:

| # | SKU | Name | Category | Price | Qty | Reorder |
|---|-----|------|----------|-------|-----|---------|
| 1 | ELC-1001-0001 | Wireless Mouse | Electronics | $29.99 | 150 | 25 |
| 2 | ELC-1002-0002 | USB-C Hub | Electronics | $49.99 | 8 | 15 |
| 3 | CLT-2001-0001 | Cotton T-Shirt | Clothing | $19.99 | 200 | 30 |
| 4 | CLT-2002-0002 | Denim Jeans | Clothing | $45.99 | 5 | 20 |
| 5 | FOD-3001-0001 | Organic Coffee Beans | Food | $12.99 | 300 | 50 |
| 6 | FOD-3002-0002 | Green Tea Box | Food | $8.99 | 0 | 25 |
| 7 | FRN-4001-0001 | Office Desk | Furniture | $299.99 | 12 | 5 |
| 8 | FRN-4002-0002 | Ergonomic Chair | Furniture | $449.99 | 3 | 5 |
| 9 | OFS-5001-0001 | A4 Paper Ream | Office Supplies | $5.99 | 500 | 100 |
| 10 | OTH-6001-0001 | First Aid Kit | Other | $24.99 | 10 | 10 |

- Same 3 demo users:

| Username | Password | Role | Full Name |
|----------|----------|------|-----------|
| admin | admin123 | Admin | System Administrator |
| manager | manager123 | Manager | Store Manager |
| clerk | clerk123 | Clerk | Store Clerk |

---

## 7. Target Technology Stack

| Layer | Technology | Details |
|-------|-----------|---------|
| Framework | Angular 19 | Latest version with standalone components |
| Language | TypeScript (strict mode) | Interfaces, enums, type safety |
| Styling | SCSS | CSS variables for theming, responsive design |
| State | RxJS BehaviorSubject | In-memory reactive data store |
| Routing | Angular Router | `/login`, `/dashboard`, `/product/:id` |
| Auth Guard | Angular functional guard | `canActivate` protecting `/dashboard` and `/product` routes |
| Forms | Reactive Forms | `FormGroup`, `FormControl`, custom validators |
| Components | Standalone | No `NgModule` declarations; imports directly in component |
| Theme | CSS Variables | Dark/light toggle with `localStorage` persistence |

---

## 8. Dark/Light Theme Support (New Feature)

This is a new feature not present in the VB6 application.

| Requirement | Description |
|-------------|-------------|
| Theme toggle | Button/switch accessible from login page and dashboard header |
| Persistence | Selected theme saved to `localStorage`, restored on app load |
| CSS variables | 40+ CSS custom properties for colors, backgrounds, borders, shadows |
| Smooth transition | `transition: all 0.3s ease` on theme change |
| Default theme | Light theme on first visit |
| Scope | All components must support both themes |

### Theme Color Variables (minimum)
- `--bg-primary`, `--bg-secondary`, `--bg-card` — background colors
- `--text-primary`, `--text-secondary` — text colors
- `--border-color` — border colors
- `--input-bg`, `--input-border`, `--input-text` — form control colors
- `--btn-primary-bg`, `--btn-primary-text` — button colors
- `--table-header-bg`, `--table-row-hover` — table colors
- `--status-bar-bg` — status bar color
- `--low-stock-bg`, `--out-of-stock-bg` — alert highlighting colors
- `--modal-backdrop`, `--modal-bg` — modal colors
- `--shadow-color` — box shadow colors

---

## 9. Routing & Navigation

| Route | Component | Guard | Description |
|-------|-----------|-------|-------------|
| `/login` | LoginComponent | None | Public route, redirects to `/dashboard` if already authenticated |
| `/dashboard` | DashboardComponent | AuthGuard | Protected; redirects to `/login` if not authenticated |
| `/product/new` | ProductFormComponent | AuthGuard | Add new product (Admin/Manager only) |
| `/product/:id` | ProductFormComponent | AuthGuard | Edit existing product (Admin/Manager only) |
| `**` (wildcard) | Redirect to `/login` | None | Catch-all redirect |

### Auth Guard Logic
- Check `AuthService.isAuthenticated()` (verifies `currentUser` is not null)
- If authenticated → allow navigation
- If not authenticated → redirect to `/login`

---

## 10. Validation Rules (Preserved from VB6)

| Field | Rule | VB6 Source | Angular Implementation |
|-------|------|-----------|----------------------|
| SKU | Format: `XXX-XXXX-XXXX` (alphanumeric, 14 chars with dashes) | `IsValidSKU()` in `modUtilities.bas` | Custom `Validators` function |
| SKU | Required for new products | `IsRequiredField()` | `Validators.required` |
| SKU | Unique (no duplicates) | `GetProductBySKU()` check in `clsInventory` | Service-level async validation |
| SKU | Read-only in edit mode | `txtSKU.Enabled = False` | `[readonly]` attribute |
| Product Name | Required, max 100 characters | `IsRequiredField()`, `PRODUCT_NAME_MAX` | `Validators.required`, `Validators.maxLength(100)` |
| Category | Required (must select one) | `cboCategory.ListIndex = -1` check | `Validators.required` |
| Price | Range: $0.01 - $999,999.99 | `IsValidPrice()` | Custom range validator |
| Price | Must be numeric | `IsNumeric()` check | Pattern/custom validator |
| Quantity | Range: 0 - 999,999 | `IsValidQuantity()` | Custom range validator |
| Quantity | Must be whole number | `InStr(QtyStr, ".") > 0` check | Custom integer validator |
| Reorder Level | Range: 0 - 999,999 | Same as Quantity validation | Custom range validator |
| Username | Required | `Len(Username) = 0` check | `Validators.required` |
| Password | Required | `Len(Password) = 0` check | `Validators.required` |

---

## 11. Non-Functional Requirements

| Requirement | Description |
|-------------|-------------|
| Browser Support | Modern browsers (Chrome, Firefox, Edge, Safari) |
| Responsive | Desktop-first with basic mobile responsiveness |
| Performance | Instant in-memory operations; no API latency |
| Accessibility | Semantic HTML, form labels, keyboard navigation |
| Code Style | Standalone components, strict TypeScript, SCSS |
| Build | Must pass `ng build` with zero errors |
| No External UI Library | Pure Angular + custom SCSS (no Material, Bootstrap, etc.) |
