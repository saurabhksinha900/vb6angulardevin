# VB6 to Angular 19 Migration — Architecture & Design

## 1. Angular Project Structure

```
src/
├── app/
│   ├── models/
│   │   ├── product.model.ts          # Product interface + helper functions
│   │   └── user.model.ts             # User interface + permission functions
│   ├── services/
│   │   ├── auth.service.ts           # Authentication, session, login attempts
│   │   ├── inventory.service.ts      # Product CRUD, search, filter, reports
│   │   ├── utility.service.ts        # Validation, formatting helpers
│   │   └── theme.service.ts          # Dark/light theme toggle + persistence
│   ├── guards/
│   │   └── auth.guard.ts             # Route protection (canActivate)
│   ├── components/
│   │   ├── login/
│   │   │   ├── login.component.ts
│   │   │   ├── login.component.html
│   │   │   └── login.component.scss
│   │   ├── dashboard/
│   │   │   ├── dashboard.component.ts
│   │   │   ├── dashboard.component.html
│   │   │   └── dashboard.component.scss
│   │   ├── product-form/
│   │   │   ├── product-form.component.ts
│   │   │   ├── product-form.component.html
│   │   │   └── product-form.component.scss
│   │   ├── report/
│   │   │   ├── report.component.ts
│   │   │   ├── report.component.html
│   │   │   └── report.component.scss
│   │   └── about/
│   │       ├── about.component.ts
│   │       ├── about.component.html
│   │       └── about.component.scss
│   ├── constants.ts                  # Enums, validation ranges, app metadata
│   ├── app.component.ts              # Root component with router-outlet
│   ├── app.component.html
│   ├── app.component.scss
│   ├── app.routes.ts                 # Route configuration
│   └── app.config.ts                 # Application providers
├── styles.scss                       # Global styles + CSS variable system
├── index.html                        # Entry HTML
└── main.ts                           # Bootstrap
```

---

## 2. TypeScript Interfaces

### 2.1 Product Interface (`product.model.ts`)

```typescript
import { ProductCategory } from '../constants';

export interface Product {
  productId: number;
  sku: string;
  productName: string;
  description: string;
  category: ProductCategory;
  unitPrice: number;
  quantityInStock: number;
  reorderLevel: number;
  dateAdded: Date;
  lastModified: Date;
  isActive: boolean;
}
```

**Helper Functions:**

```typescript
export function createDefaultProduct(): Product {
  return {
    productId: 0,
    sku: '',
    productName: '',
    description: '',
    category: ProductCategory.Other,
    unitPrice: 0,
    quantityInStock: 0,
    reorderLevel: 0,
    dateAdded: new Date(),
    lastModified: new Date(),
    isActive: true
  };
}

export function isLowStock(product: Product): boolean {
  return product.quantityInStock <= product.reorderLevel;
}

export function isOutOfStock(product: Product): boolean {
  return product.quantityInStock === 0;
}

export function totalValue(product: Product): number {
  return product.unitPrice * product.quantityInStock;
}

export function getProductStatus(product: Product): string {
  if (product.quantityInStock === 0) return 'Out of Stock';
  if (product.quantityInStock <= product.reorderLevel) return 'Low Stock';
  return 'OK';
}
```

### 2.2 User Interface (`user.model.ts`)

```typescript
import { UserRole } from '../constants';

export interface User {
  userId: number;
  username: string;
  passwordHash: string;
  fullName: string;
  role: UserRole;
  isActive: boolean;
  loginAttempts: number;
  lastLoginDate: Date | null;
}
```

**Permission Functions:**

```typescript
export function canEditProducts(user: User): boolean {
  return user.role === UserRole.Admin || user.role === UserRole.Manager;
}

export function canDeleteProducts(user: User): boolean {
  return user.role === UserRole.Admin;
}

export function canManageUsers(user: User): boolean {
  return user.role === UserRole.Admin;
}

export function canGenerateReports(user: User): boolean {
  return true; // All roles
}
```

---

## 3. Enums & Constants (`constants.ts`)

```typescript
export enum ProductCategory {
  Electronics = 1,
  Clothing = 2,
  Food = 3,
  Furniture = 4,
  OfficeSupplies = 5,
  Other = 6
}

export enum UserRole {
  Admin = 1,
  Manager = 2,
  Clerk = 3
}

export const CATEGORY_NAMES: Record<ProductCategory, string> = {
  [ProductCategory.Electronics]: 'Electronics',
  [ProductCategory.Clothing]: 'Clothing',
  [ProductCategory.Food]: 'Food',
  [ProductCategory.Furniture]: 'Furniture',
  [ProductCategory.OfficeSupplies]: 'Office Supplies',
  [ProductCategory.Other]: 'Other'
};

export const ROLE_NAMES: Record<UserRole, string> = {
  [UserRole.Admin]: 'Admin',
  [UserRole.Manager]: 'Manager',
  [UserRole.Clerk]: 'Clerk'
};

export const APP_NAME = 'Inventory Management System';
export const APP_VERSION = '2.0.0';
export const APP_DESCRIPTION = 'A comprehensive inventory management solution migrated from VB6 to Angular 19';
export const APP_DEVELOPER = 'Development Team';
export const APP_COPYRIGHT = 'Copyright (c) 2024';

export const MAX_LOGIN_ATTEMPTS = 3;

export const SKU_LENGTH = 14;
export const SKU_PATTERN = /^[A-Za-z0-9]{3}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}$/;
export const PRODUCT_NAME_MAX = 100;
export const PRICE_MIN = 0.01;
export const PRICE_MAX = 999999.99;
export const QTY_MIN = 0;
export const QTY_MAX = 999999;

export enum ReportType {
  Summary = 1,
  ByCategory = 2,
  LowStock = 3,
  InventoryValue = 4
}
```

---

## 4. Service Method Signatures

### 4.1 AuthService (`auth.service.ts`)

```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  private currentUserSubject: BehaviorSubject<User | null>;
  currentUser$: Observable<User | null>;
  private loginAttempts: number;
  private isLockedOut: boolean;

  constructor() { /* Initialize with 3 demo users */ }

  authenticate(username: string, password: string): boolean
    // Hash password, find matching user, update currentUser subject
    // Increment loginAttempts on failure, lock out after MAX_LOGIN_ATTEMPTS

  logout(): void
    // Clear currentUser, navigate to /login

  isAuthenticated(): boolean
    // Return currentUserSubject.value !== null

  getCurrentUser(): User | null
    // Return currentUserSubject.value

  getRemainingAttempts(): number
    // Return MAX_LOGIN_ATTEMPTS - loginAttempts

  isAccountLocked(): boolean
    // Return isLockedOut

  private simpleHash(password: string): string
    // Replicate VB6 HashPassword: hash=5381, loop: hash = ((hash*33) XOR charCode) & 0x7FFFFFFF
    // Return hex string
}
```

**Demo Users (seeded in constructor):**
| Username | Password | Hash | Role | Full Name |
|----------|----------|------|------|-----------|
| admin | admin123 | (computed) | Admin | System Administrator |
| manager | manager123 | (computed) | Manager | Store Manager |
| clerk | clerk123 | (computed) | Clerk | Store Clerk |

### 4.2 InventoryService (`inventory.service.ts`)

```typescript
@Injectable({ providedIn: 'root' })
export class InventoryService {
  private productsSubject: BehaviorSubject<Product[]>;
  products$: Observable<Product[]>;
  private nextId: number;

  constructor() { /* Seed 10 products */ }

  getProducts(): Product[]
    // Return current snapshot

  getProductById(id: number): Product | undefined
    // Find by productId

  addProduct(product: Product): boolean
    // Validate, check duplicate SKU, assign ID, push to array, emit

  updateProduct(product: Product): boolean
    // Find by ID, update fields, emit

  deleteProduct(id: number): boolean
    // Filter out by ID, emit

  searchProducts(name: string, category: ProductCategory | null): Product[]
    // Filter by name (case-insensitive contains) and/or category

  getProductCount(): number
  getTotalInventoryValue(): number
  getLowStockCount(): number
  getAveragePrice(): number
  getTotalQuantity(): number
  getCategoryCount(): number

  // Report generation methods
  generateSummaryReport(): string
  generateCategoryReport(): string
  generateLowStockReport(): string
  generateValueReport(): string

  isSkuUnique(sku: string, excludeId?: number): boolean
    // Check if SKU already exists (excluding given product ID for edits)
}
```

**Seed Products (10 items, same as VB6):**
| # | SKU | Name | Category | Price | Qty | Reorder |
|---|-----|------|----------|-------|-----|---------|
| 1 | ELC-1001-0001 | Wireless Mouse | Electronics | 29.99 | 150 | 25 |
| 2 | ELC-1002-0002 | USB-C Hub | Electronics | 49.99 | 8 | 15 |
| 3 | CLT-2001-0001 | Cotton T-Shirt | Clothing | 19.99 | 200 | 30 |
| 4 | CLT-2002-0002 | Denim Jeans | Clothing | 45.99 | 5 | 20 |
| 5 | FOD-3001-0001 | Organic Coffee Beans | Food | 12.99 | 300 | 50 |
| 6 | FOD-3002-0002 | Green Tea Box | Food | 8.99 | 0 | 25 |
| 7 | FRN-4001-0001 | Office Desk | Furniture | 299.99 | 12 | 5 |
| 8 | FRN-4002-0002 | Ergonomic Chair | Furniture | 449.99 | 3 | 5 |
| 9 | OFS-5001-0001 | A4 Paper Ream | Office Supplies | 5.99 | 500 | 100 |
| 10 | OTH-6001-0001 | First Aid Kit | Other | 24.99 | 10 | 10 |

### 4.3 UtilityService (`utility.service.ts`)

```typescript
@Injectable({ providedIn: 'root' })
export class UtilityService {

  formatCurrency(amount: number): string
    // Return formatted string like "$1,234.56"

  isValidSKU(sku: string): boolean
    // Test against SKU_PATTERN regex (XXX-XXXX-XXXX, alphanumeric)

  isValidPrice(value: number): boolean
    // Check PRICE_MIN <= value <= PRICE_MAX

  isValidQuantity(value: number): boolean
    // Check QTY_MIN <= value <= QTY_MAX and is integer

  generateSKU(category: ProductCategory): string
    // Auto-generate SKU based on category prefix + random digits

  formatDate(date: Date): string
    // Return "YYYY-MM-DD HH:mm:ss"

  padString(text: string, length: number): string
    // Pad or truncate to fixed width for report formatting
}
```

### 4.4 ThemeService (`theme.service.ts`)

```typescript
@Injectable({ providedIn: 'root' })
export class ThemeService {
  private isDarkSubject: BehaviorSubject<boolean>;
  isDark$: Observable<boolean>;

  private readonly STORAGE_KEY = 'inventory-theme-dark';

  constructor() {
    // Read from localStorage, default to false (light theme)
  }

  toggleTheme(): void
    // Flip isDark, save to localStorage, apply to document

  isDark(): boolean
    // Return current value

  private applyTheme(isDark: boolean): void
    // Add/remove 'dark-theme' class on document.body
}
```

---

## 5. Route Configuration (`app.routes.ts`)

```typescript
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./components/login/login.component').then(m => m.LoginComponent) },
  { path: 'dashboard', loadComponent: () => import('./components/dashboard/dashboard.component').then(m => m.DashboardComponent), canActivate: [authGuard] },
  { path: 'product/new', loadComponent: () => import('./components/product-form/product-form.component').then(m => m.ProductFormComponent), canActivate: [authGuard] },
  { path: 'product/:id', loadComponent: () => import('./components/product-form/product-form.component').then(m => m.ProductFormComponent), canActivate: [authGuard] },
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: '**', redirectTo: '/login' }
];
```

---

## 6. Auth Guard (`auth.guard.ts`)

```typescript
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};
```

---

## 7. CSS Variable System for Dark/Light Theming

### 7.1 Light Theme (Default)

```scss
:root {
  // Backgrounds
  --bg-primary: #ffffff;
  --bg-secondary: #f5f7fa;
  --bg-card: #ffffff;
  --bg-input: #ffffff;
  --bg-hover: #f0f2f5;

  // Text
  --text-primary: #1a1a2e;
  --text-secondary: #6b7280;
  --text-muted: #9ca3af;
  --text-inverse: #ffffff;

  // Borders
  --border-color: #e5e7eb;
  --border-focus: #3b82f6;

  // Buttons
  --btn-primary-bg: #3b82f6;
  --btn-primary-text: #ffffff;
  --btn-primary-hover: #2563eb;
  --btn-danger-bg: #ef4444;
  --btn-danger-text: #ffffff;
  --btn-danger-hover: #dc2626;
  --btn-secondary-bg: #6b7280;
  --btn-secondary-text: #ffffff;
  --btn-success-bg: #10b981;
  --btn-success-text: #ffffff;

  // Table
  --table-header-bg: #f9fafb;
  --table-header-text: #374151;
  --table-row-hover: #f3f4f6;
  --table-border: #e5e7eb;

  // Status
  --low-stock-bg: #fef3c7;
  --low-stock-text: #92400e;
  --out-of-stock-bg: #fee2e2;
  --out-of-stock-text: #991b1b;
  --ok-stock-bg: #d1fae5;
  --ok-stock-text: #065f46;

  // Status bar
  --status-bar-bg: #f9fafb;
  --status-bar-text: #374151;
  --status-bar-border: #e5e7eb;

  // Modal
  --modal-backdrop: rgba(0, 0, 0, 0.5);
  --modal-bg: #ffffff;

  // Inputs
  --input-bg: #ffffff;
  --input-border: #d1d5db;
  --input-text: #1a1a2e;
  --input-placeholder: #9ca3af;
  --input-focus-border: #3b82f6;
  --input-focus-shadow: rgba(59, 130, 246, 0.25);
  --input-disabled-bg: #f3f4f6;

  // Misc
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
  --header-bg: #1e293b;
  --header-text: #ffffff;
  --link-color: #3b82f6;
  --scrollbar-thumb: #cbd5e1;
  --scrollbar-track: #f1f5f9;
}
```

### 7.2 Dark Theme

```scss
body.dark-theme {
  // Backgrounds
  --bg-primary: #0f172a;
  --bg-secondary: #1e293b;
  --bg-card: #1e293b;
  --bg-input: #334155;
  --bg-hover: #334155;

  // Text
  --text-primary: #f1f5f9;
  --text-secondary: #94a3b8;
  --text-muted: #64748b;
  --text-inverse: #0f172a;

  // Borders
  --border-color: #334155;
  --border-focus: #60a5fa;

  // Buttons
  --btn-primary-bg: #3b82f6;
  --btn-primary-text: #ffffff;
  --btn-primary-hover: #60a5fa;
  --btn-danger-bg: #ef4444;
  --btn-danger-text: #ffffff;
  --btn-danger-hover: #f87171;
  --btn-secondary-bg: #475569;
  --btn-secondary-text: #f1f5f9;
  --btn-success-bg: #10b981;
  --btn-success-text: #ffffff;

  // Table
  --table-header-bg: #1e293b;
  --table-header-text: #e2e8f0;
  --table-row-hover: #334155;
  --table-border: #334155;

  // Status
  --low-stock-bg: #78350f;
  --low-stock-text: #fef3c7;
  --out-of-stock-bg: #7f1d1d;
  --out-of-stock-text: #fee2e2;
  --ok-stock-bg: #064e3b;
  --ok-stock-text: #d1fae5;

  // Status bar
  --status-bar-bg: #1e293b;
  --status-bar-text: #e2e8f0;
  --status-bar-border: #334155;

  // Modal
  --modal-backdrop: rgba(0, 0, 0, 0.7);
  --modal-bg: #1e293b;

  // Inputs
  --input-bg: #334155;
  --input-border: #475569;
  --input-text: #f1f5f9;
  --input-placeholder: #64748b;
  --input-focus-border: #60a5fa;
  --input-focus-shadow: rgba(96, 165, 250, 0.25);
  --input-disabled-bg: #1e293b;

  // Misc
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
  --header-bg: #0f172a;
  --header-text: #f1f5f9;
  --link-color: #60a5fa;
  --scrollbar-thumb: #475569;
  --scrollbar-track: #1e293b;
}
```

### 7.3 Transition

```scss
* {
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
}
```

---

## 8. Component Design

### 8.1 LoginComponent

**VB6 Source:** `frmLogin.frm`

**Template Structure:**
```
┌─────────────────────────────────────┐
│                    [Theme Toggle] ☀️ │
│                                     │
│     Inventory Management System     │
│          Version 2.0.0              │
│                                     │
│   ┌─────────────────────────────┐   │
│   │ Username:  [____________]   │   │
│   │ Password:  [____________]   │   │
│   │                             │   │
│   │     [ Login ]               │   │
│   │                             │   │
│   │ ⚠ Error message here        │   │
│   │                             │   │
│   │ Demo: admin/admin123        │   │
│   │       manager/manager123    │   │
│   │       clerk/clerk123        │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Reactive Form:**
```typescript
loginForm = new FormGroup({
  username: new FormControl('', [Validators.required]),
  password: new FormControl('', [Validators.required])
});
```

**Events:**
- `onSubmit()` → calls `AuthService.authenticate()`, navigates to `/dashboard` on success
- `onToggleTheme()` → calls `ThemeService.toggleTheme()`

### 8.2 DashboardComponent

**VB6 Source:** `frmMain.frm`

**Template Structure:**
```
┌─────────────────────────────────────────────────────────┐
│ Header: [App Name]  User: Admin ☀️/🌙  [Logout]        │
├─────────────────────────────────────────────────────────┤
│ [Add] [Edit] [Delete]    Search: [______] Category: [▼] │
│                          [Search] [Clear] [Refresh]     │
├───┬──────────┬────────┬──────┬───────┬─────┬────┬───────┤
│ ID│ SKU      │ Name   │ Cat  │ Price │ Qty │ RL │Status │
├───┼──────────┼────────┼──────┼───────┼─────┼────┼───────┤
│ 1 │ ELC-1001 │ Mouse  │ Elec │$29.99 │ 150 │ 25 │  OK   │
│ 2 │ ELC-1002 │ Hub    │ Elec │$49.99 │   8 │ 15 │⚠ Low  │
│ 6 │ FOD-3002 │ Tea    │ Food │ $8.99 │   0 │ 25 │🔴 Out │
├───┴──────────┴────────┴──────┴───────┴─────┴────┴───────┤
│ [Report] [About]                                        │
├─────────────────────────────────────────────────────────┤
│ User: Admin │ Products: 10 │ Low: 5 │ Value: $XX,XXX.XX │
└─────────────────────────────────────────────────────────┘
```

**Key Behaviors:**
- Product table loads from `InventoryService.products$` subscription
- Row click selects product for Edit/Delete
- RBAC: hide Add/Edit/Delete buttons based on `canEditProducts()` / `canDeleteProducts()`
- Search: filter by name (case-insensitive partial match)
- Category filter: dropdown with "(All)" + 6 categories
- Status coloring: CSS class `low-stock` (orange) or `out-of-stock` (red) on rows
- Report button opens ReportComponent as modal overlay
- About button opens AboutComponent as modal overlay
- Status bar updates reactively from InventoryService

### 8.3 ProductFormComponent

**VB6 Source:** `frmProduct.frm`

**Template Structure:**
```
┌─────────────────────────────────────┐
│         Add / Edit Product          │
│                                     │
│   SKU:          [____________] [⚡]  │
│                 (XXX-XXXX-XXXX)     │
│   Product Name: [____________]      │
│   Category:     [▼ Electronics]     │
│   Price ($):    [____________]      │
│                 ($0.01-$999,999.99) │
│   Quantity:     [____________]      │
│                 (0-999,999)         │
│   Reorder Lvl:  [____________]      │
│                 (0-999,999)         │
│                                     │
│        [ Save ]    [ Cancel ]       │
└─────────────────────────────────────┘
```

**Reactive Form:**
```typescript
productForm = new FormGroup({
  sku: new FormControl('', [Validators.required, skuValidator]),
  productName: new FormControl('', [Validators.required, Validators.maxLength(100)]),
  category: new FormControl(null, [Validators.required]),
  unitPrice: new FormControl(null, [Validators.required, priceRangeValidator]),
  quantityInStock: new FormControl(null, [Validators.required, quantityValidator]),
  reorderLevel: new FormControl(null, [Validators.required, quantityValidator])
});
```

**Modes:**
- Route `/product/new` → Add mode (all fields editable, SKU auto-generate button)
- Route `/product/:id` → Edit mode (SKU readonly, load existing data)

**Events:**
- `onSave()` → validate form, call `InventoryService.addProduct()` or `updateProduct()`, navigate back
- `onCancel()` → navigate to `/dashboard`
- `onGenerateSKU()` → auto-generate valid SKU based on selected category

### 8.4 ReportComponent (Modal)

**VB6 Source:** `frmReport.frm`

**Template Structure:**
```
┌─────────────────────────────────────┐
│          Inventory Reports     [X]  │
│                                     │
│   Report Type:                      │
│   (●) Summary Report                │
│   ( ) By Category Report            │
│   ( ) Low Stock Alert Report        │
│   ( ) Inventory Value Report        │
│                                     │
│   [ Generate ]                      │
│                                     │
│   ┌───────────────────────────────┐ │
│   │ INVENTORY SUMMARY REPORT     │ │
│   │ Generated: 2024-01-15        │ │
│   │ ========================     │ │
│   │ Total Products: 10           │ │
│   │ Total Value: $XX,XXX.XX      │ │
│   │ ...                          │ │
│   └───────────────────────────────┘ │
│                                     │
│        [ Export ]    [ Close ]       │
└─────────────────────────────────────┘
```

**Report Types:**
1. **Summary** — Total products, inventory value, avg price, total qty, categories, low stock count
2. **By Category** — Grouped by category with count, total value, avg price per category
3. **Low Stock** — Products where qty <= reorder level, sorted by shortage descending
4. **Value** — All products sorted by total value (price * qty) descending, with grand total

**Export:** Creates a `Blob` with text content, triggers download as `Report_[Type]_[Date].txt`

### 8.5 AboutComponent (Modal)

**VB6 Source:** `frmAbout.frm`

**Template Structure:**
```
┌─────────────────────────────────────┐
│              About             [X]  │
│                                     │
│     Inventory Management System     │
│           Version 2.0.0             │
│                                     │
│   A comprehensive inventory         │
│   management solution migrated      │
│   from VB6 to Angular 19           │
│                                     │
│   Developer: Development Team       │
│   Copyright (c) 2024                │
│                                     │
│   Originally built with VB6         │
│   Migrated to Angular 19 with       │
│   TypeScript and SCSS               │
│                                     │
│              [ OK ]                 │
└─────────────────────────────────────┘
```

---

## 9. Data Flow Diagram

```
User Action
    │
    ▼
Component (LoginComponent / DashboardComponent / ProductFormComponent)
    │
    ├── AuthService ──► BehaviorSubject<User | null>
    │                       │
    │                       ▼
    │                   currentUser$ ──► Components subscribe for RBAC
    │
    ├── InventoryService ──► BehaviorSubject<Product[]>
    │                           │
    │                           ▼
    │                       products$ ──► DashboardComponent subscribes
    │                                     for table display + status bar
    │
    ├── UtilityService ──► Pure functions (validation, formatting)
    │
    └── ThemeService ──► BehaviorSubject<boolean>
                             │
                             ▼
                         isDark$ ──► Components subscribe for toggle state
                                     body.dark-theme class applied/removed
```

---

## 10. VB6 to Angular Migration Mapping Summary

| VB6 Element | Angular Element | Type |
|-------------|----------------|------|
| `frmLogin` | `LoginComponent` | Standalone Component |
| `frmMain` | `DashboardComponent` | Standalone Component |
| `frmProduct` | `ProductFormComponent` | Standalone Component |
| `frmReport` | `ReportComponent` | Standalone Component (Modal) |
| `frmAbout` | `AboutComponent` | Standalone Component (Modal) |
| `modConstants.bas` | `constants.ts` | TypeScript file |
| `modDatabase.bas` | `InventoryService` + `AuthService` | Injectable Services |
| `modUtilities.bas` | `UtilityService` | Injectable Service |
| `clsProduct.cls` | `Product` interface + helper functions | TypeScript interface |
| `clsUser.cls` | `User` interface + permission functions | TypeScript interface |
| `clsInventory.cls` | Absorbed into `InventoryService` | Service methods |
| `g_Connection` (global) | `BehaviorSubject` in services | Reactive state |
| `g_CurrentUser` (global) | `AuthService.currentUser$` | Observable |
| `On Error GoTo` | `try/catch` blocks | Error handling |
| `MsgBox` | `window.alert()` / inline error display | User feedback |
| `Show vbModal` | Angular Router / modal overlay | Navigation |
| ADO SQL queries | Array operations (`filter`, `find`, `reduce`) | Data operations |
| `ADODB.Recordset` | `Product[]` array | Data structure |
| VB6 events (`_Click`, `_Load`) | Angular lifecycle hooks + event bindings | Event handling |
| `HashPassword` (XOR) | `simpleHash()` in AuthService | Authentication |
