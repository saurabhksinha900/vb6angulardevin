# VB6 Inventory Management System - Test Cases

## 1. Login Tests

### TC-LOGIN-001: Valid Admin Login
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "admin" in Username field<br>2. Enter "admin123" in Password field<br>3. Click Login button |
| **Expected Result** | Login succeeds. frmLogin closes. frmMain opens with title showing "System Administrator (Admin)". Status bar shows "User: System Administrator (Admin)". All buttons (Add, Edit, Delete, Report, Refresh) are enabled. |

### TC-LOGIN-002: Valid Manager Login
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "manager" in Username field<br>2. Enter "manager123" in Password field<br>3. Click Login button |
| **Expected Result** | Login succeeds. frmMain opens. Status bar shows "User: Store Manager (Manager)". Add and Edit buttons enabled. Delete button disabled. |

### TC-LOGIN-003: Valid Clerk (Supervisor) Login
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "clerk" in Username field<br>2. Enter "clerk123" in Password field<br>3. Click Login button |
| **Expected Result** | Login succeeds. frmMain opens. Status bar shows "User: Store Clerk (Supervisor)". Add, Edit, and Delete buttons all disabled. Report and Refresh buttons enabled. |

### TC-LOGIN-004: Invalid Username
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "wronguser" in Username field<br>2. Enter "admin123" in Password field<br>3. Click Login button |
| **Expected Result** | Login fails. Status label shows "Invalid credentials. 2 attempt(s) remaining." Password field is cleared. Focus moves to Password field. |

### TC-LOGIN-005: Invalid Password
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "admin" in Username field<br>2. Enter "wrongpassword" in Password field<br>3. Click Login button |
| **Expected Result** | Login fails. Status label shows "Invalid credentials. 2 attempt(s) remaining." Password field is cleared. |

### TC-LOGIN-006: Empty Username
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Leave Username field empty<br>2. Enter "admin123" in Password field<br>3. Click Login button |
| **Expected Result** | Status label shows "Please enter a username." Focus moves to Username field. No login attempt counted. |

### TC-LOGIN-007: Empty Password
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "admin" in Username field<br>2. Leave Password field empty<br>3. Click Login button |
| **Expected Result** | Status label shows "Please enter a password." Focus moves to Password field. No login attempt counted. |

### TC-LOGIN-008: Lockout After 3 Failed Attempts
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "admin" / "wrong1" → Click Login (Attempt 1)<br>2. Enter "admin" / "wrong2" → Click Login (Attempt 2)<br>3. Enter "admin" / "wrong3" → Click Login (Attempt 3) |
| **Expected Result** | After attempt 1: "2 attempt(s) remaining"<br>After attempt 2: "1 attempt(s) remaining"<br>After attempt 3: MsgBox "Maximum login attempts exceeded. The application will now close." Application terminates. |

### TC-LOGIN-009: Successful Login After Failed Attempts
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Enter "admin" / "wrong1" → Click Login (Attempt 1)<br>2. Enter "admin" / "admin123" → Click Login |
| **Expected Result** | After attempt 1: "2 attempt(s) remaining"<br>After attempt 2: Login succeeds. frmMain opens normally. |

### TC-LOGIN-010: Exit Button
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Click Exit button |
| **Expected Result** | Application terminates. Database connection is closed. |

### TC-LOGIN-011: Password Masking
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Application launched, frmLogin displayed |
| **Steps** | 1. Type "admin123" in Password field |
| **Expected Result** | Characters displayed as asterisks (*). Actual text value is "admin123". |

---

## 2. CRUD Tests

### TC-CRUD-001: Add Product - Valid Data
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as admin. frmMain displayed. |
| **Steps** | 1. Click Add button<br>2. Enter SKU: "TST-0001-0001"<br>3. Enter Name: "Test Product"<br>4. Select Category: "Electronics"<br>5. Enter Price: "25.99"<br>6. Enter Quantity: "100"<br>7. Enter Reorder Level: "20"<br>8. Click Save |
| **Expected Result** | MsgBox "Product added successfully." frmProduct closes. ListView refreshes showing the new product. Product count in status bar increments by 1. |

### TC-CRUD-002: Add Product - Duplicate SKU
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in as admin. Product with SKU "ELC-1001-0001" already exists. |
| **Steps** | 1. Click Add button<br>2. Enter SKU: "ELC-1001-0001"<br>3. Fill remaining fields with valid data<br>4. Click Save |
| **Expected Result** | MsgBox "A product with SKU 'ELC-1001-0001' already exists." Form remains open. Product is not added. |

### TC-CRUD-003: Edit Product - Valid Update
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as admin. Products visible in ListView. |
| **Steps** | 1. Click on "Wireless Mouse" in ListView<br>2. Click Edit button<br>3. Change Name to "Wireless Mouse Pro"<br>4. Change Price to "34.99"<br>5. Click Save |
| **Expected Result** | MsgBox "Product updated successfully." frmProduct closes. ListView shows updated name "Wireless Mouse Pro" and price "$34.99". SKU field was read-only during edit. |

### TC-CRUD-004: Edit Product - No Selection
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. No product selected in ListView. |
| **Steps** | 1. Click Edit button (without selecting a product) |
| **Expected Result** | MsgBox "Please select a product to edit." frmProduct does not open. |

### TC-CRUD-005: Delete Product - Confirm Yes
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as admin. Products visible in ListView. |
| **Steps** | 1. Click on a product in ListView<br>2. Click Delete button<br>3. Click "Yes" on confirmation dialog |
| **Expected Result** | MsgBox "Product deleted successfully." ListView refreshes. Deleted product no longer appears. Product count decrements. |

### TC-CRUD-006: Delete Product - Confirm No
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. Products visible in ListView. |
| **Steps** | 1. Click on a product in ListView<br>2. Click Delete button<br>3. Click "No" on confirmation dialog |
| **Expected Result** | Deletion cancelled. Product still appears in ListView. No changes made. |

### TC-CRUD-007: Delete Product - No Selection
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. No product selected. |
| **Steps** | 1. Click Delete button |
| **Expected Result** | MsgBox "Please select a product to delete." No deletion occurs. |

### TC-CRUD-008: Add Product - SKU Read-Only in Edit Mode
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. Product selected. |
| **Steps** | 1. Click Edit button<br>2. Attempt to modify SKU field |
| **Expected Result** | SKU field is disabled (grayed out). Cannot type or modify the value. |

---

## 3. RBAC Tests

### TC-RBAC-001: Admin - Full Access
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as admin (admin/admin123). |
| **Steps** | 1. Verify toolbar buttons state<br>2. Verify menu items state<br>3. Attempt Add, Edit, Delete operations |
| **Expected Result** | Add button: Enabled. Edit button: Enabled. Delete button: Enabled. Report button: Enabled. All menu items under Products enabled. All CRUD operations succeed. |

### TC-RBAC-002: Manager - View and Edit Only
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as manager (manager/manager123). |
| **Steps** | 1. Verify toolbar buttons state<br>2. Verify menu items state<br>3. Attempt Add and Edit operations<br>4. Verify Delete button is disabled |
| **Expected Result** | Add button: Enabled. Edit button: Enabled. Delete button: Disabled. Report button: Enabled. Add Product menu: Enabled. Edit Product menu: Enabled. Delete Product menu: Disabled. Add and Edit operations succeed. Cannot delete. |

### TC-RBAC-003: Supervisor - View Only
| Field | Value |
|-------|-------|
| **Priority** | Critical |
| **Precondition** | Logged in as clerk (clerk/clerk123). |
| **Steps** | 1. Verify toolbar buttons state<br>2. Verify menu items state |
| **Expected Result** | Add button: Disabled. Edit button: Disabled. Delete button: Disabled. Report button: Enabled. Refresh button: Enabled. All Product menu items (Add, Edit, Delete) disabled. Can still view products in ListView. Can generate reports. |

### TC-RBAC-004: Supervisor - Search and Filter Access
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as clerk (clerk/clerk123). |
| **Steps** | 1. Type "Mouse" in search field<br>2. Click Search<br>3. Select "Electronics" from category filter<br>4. Click Search |
| **Expected Result** | Search and filter work correctly. ListView updates with filtered results. Supervisor can view and search but not modify data. |

### TC-RBAC-005: Supervisor - Report Access
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as clerk (clerk/clerk123). |
| **Steps** | 1. Click Report button<br>2. Generate each report type<br>3. Export a report |
| **Expected Result** | All 4 report types generate successfully. Export to text file works. Supervisor has full report access. |

---

## 4. Search and Filter Tests

### TC-SEARCH-001: Search by Product Name - Partial Match
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Enter "Mouse" in search field<br>2. Click Search |
| **Expected Result** | ListView shows only "Wireless Mouse". Other products hidden. |

### TC-SEARCH-002: Search by Product Name - Case Insensitive
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Enter "mouse" in search field (lowercase)<br>2. Click Search |
| **Expected Result** | ListView shows "Wireless Mouse". Search is case-insensitive. |

### TC-SEARCH-003: Search - No Results
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Enter "XYZ123NOTEXIST" in search field<br>2. Click Search |
| **Expected Result** | ListView shows no products (empty). |

### TC-SEARCH-004: Filter by Category - Electronics
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Select "Electronics" from category dropdown<br>2. Click Search |
| **Expected Result** | ListView shows only "Wireless Mouse" and "USB-C Hub" (2 products). |

### TC-SEARCH-005: Filter by Category - All
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. Category filter set to "Electronics". |
| **Steps** | 1. Select "(All)" from category dropdown<br>2. Click Search |
| **Expected Result** | ListView shows all 10 products. |

### TC-SEARCH-006: Combined Search and Filter
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Enter "Cotton" in search field<br>2. Select "Clothing" from category dropdown<br>3. Click Search |
| **Expected Result** | ListView shows only "Cotton T-Shirt". |

### TC-SEARCH-007: Clear/Reset Search
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. Search active with filtered results. |
| **Steps** | 1. Click Clear button |
| **Expected Result** | Search field cleared. Category dropdown reset to "(All)". ListView shows all 10 products. |

### TC-SEARCH-008: Filter by Each Category
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. frmMain with default 10 products. |
| **Steps** | 1. Filter by "Electronics" → Verify 2 products<br>2. Filter by "Clothing" → Verify 2 products<br>3. Filter by "Food" → Verify 2 products<br>4. Filter by "Furniture" → Verify 2 products<br>5. Filter by "Office Supplies" → Verify 1 product<br>6. Filter by "Other" → Verify 1 product |
| **Expected Result** | Each category filter returns the correct number of products matching the seed data. |

---

## 5. Report Generation Tests

### TC-REPORT-001: Summary Report
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmReport opened. Default 10 seed products. |
| **Steps** | 1. Select "Summary Report" option<br>2. Click Generate |
| **Expected Result** | Report displays: Total Products = 10, Total Inventory Value (calculated from seed data), Average Product Price, Total Quantity in Stock, Categories with Products = 6, Low Stock Items count. Report header shows title and timestamp. |

### TC-REPORT-002: By Category Report
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmReport opened. Default 10 seed products. |
| **Steps** | 1. Select "By Category Report" option<br>2. Click Generate |
| **Expected Result** | Report shows 6 categories (Clothing, Electronics, Food, Furniture, Office Supplies, Other) with product count, total value, and average price for each. Categories sorted alphabetically. |

### TC-REPORT-003: Low Stock Alert Report
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmReport opened. Default 10 seed products. |
| **Steps** | 1. Select "Low Stock Alert Report" option<br>2. Click Generate |
| **Expected Result** | Report lists products where Qty <= Reorder Level. Expected low stock items from seed data: USB-C Hub (8/15), Denim Jeans (5/20), Green Tea Box (0/25), Ergonomic Chair (3/5), First Aid Kit (10/10). Sorted by shortage (most critical first). Shows SKU, Name, Category, Current Qty, Reorder Level, Shortage. |

### TC-REPORT-004: Inventory Value Report
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. frmReport opened. Default 10 seed products. |
| **Steps** | 1. Select "Inventory Value Report" option<br>2. Click Generate |
| **Expected Result** | Report lists all products sorted by total value (Price x Quantity) descending. Shows SKU, Name, Price, Quantity, Total Value. Grand total at bottom matches sum of all product values. |

### TC-REPORT-005: Export Report to Text File
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. A report has been generated in frmReport. |
| **Steps** | 1. Generate any report<br>2. Click Export<br>3. Enter file path in dialog<br>4. Confirm save |
| **Expected Result** | MsgBox "Report exported successfully to: [path]". File created at specified path. File contents match the report text displayed in the TextBox. |

### TC-REPORT-006: Export Without Generating
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Logged in. frmReport opened. No report generated yet. |
| **Steps** | 1. Click Export (without generating a report first) |
| **Expected Result** | Export button is disabled (since no report has been generated). Or MsgBox "No report to export." |

### TC-REPORT-007: Export Cancel
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Logged in. A report has been generated. |
| **Steps** | 1. Click Export<br>2. Leave file path empty or click Cancel |
| **Expected Result** | Export cancelled. No file is saved. No error message. |

---

## 6. Validation Tests

### TC-VAL-001: SKU Format - Valid
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter SKU: "ABC-1234-5678"<br>2. Fill other fields with valid data<br>3. Click Save |
| **Expected Result** | SKU validation passes. Product is saved successfully. |

### TC-VAL-002: SKU Format - Invalid (Missing Dashes)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter SKU: "ABC12345678"<br>2. Click Save |
| **Expected Result** | MsgBox "SKU must be in format XXX-XXXX-XXXX (alphanumeric characters)." Product not saved. |

### TC-VAL-003: SKU Format - Invalid (Wrong Length)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter SKU: "AB-123-456"<br>2. Click Save |
| **Expected Result** | Validation error for SKU format. Product not saved. |

### TC-VAL-004: SKU Format - Invalid (Special Characters)
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter SKU: "AB!-12@3-45#6"<br>2. Click Save |
| **Expected Result** | Validation error for SKU format (special characters not allowed). |

### TC-VAL-005: Price - Minimum Boundary ($0.01)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter valid SKU and Name<br>2. Enter Price: "0.01"<br>3. Fill other valid fields<br>4. Click Save |
| **Expected Result** | Validation passes. Product saved with price $0.01. |

### TC-VAL-006: Price - Below Minimum ($0.00)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter valid SKU and Name<br>2. Enter Price: "0.00"<br>3. Click Save |
| **Expected Result** | MsgBox "Price must be a number between $0.01 and $999,999.99." Product not saved. |

### TC-VAL-007: Price - Maximum Boundary ($999,999.99)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter valid SKU and Name<br>2. Enter Price: "999999.99"<br>3. Fill other valid fields<br>4. Click Save |
| **Expected Result** | Validation passes. Product saved with price $999,999.99. |

### TC-VAL-008: Price - Above Maximum ($1,000,000.00)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Price: "1000000.00"<br>2. Click Save |
| **Expected Result** | Validation error for price out of range. Product not saved. |

### TC-VAL-009: Price - Non-Numeric
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Price: "abc"<br>2. Click Save |
| **Expected Result** | Validation error for price. Product not saved. |

### TC-VAL-010: Price - Negative Value
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Price: "-10.00"<br>2. Click Save |
| **Expected Result** | Validation error for price out of range. Product not saved. |

### TC-VAL-011: Quantity - Minimum Boundary (0)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Quantity: "0"<br>2. Fill other valid fields<br>3. Click Save |
| **Expected Result** | Validation passes. Product saved with quantity 0. Status shows "Out of Stock". |

### TC-VAL-012: Quantity - Maximum Boundary (999,999)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Quantity: "999999"<br>2. Fill other valid fields<br>3. Click Save |
| **Expected Result** | Validation passes. Product saved with quantity 999,999. |

### TC-VAL-013: Quantity - Above Maximum (1,000,000)
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Quantity: "1000000"<br>2. Click Save |
| **Expected Result** | Validation error for quantity out of range. Product not saved. |

### TC-VAL-014: Quantity - Negative Value
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Quantity: "-5"<br>2. Click Save |
| **Expected Result** | Validation error for quantity out of range. Product not saved. |

### TC-VAL-015: Quantity - Decimal Value
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Quantity: "10.5"<br>2. Click Save |
| **Expected Result** | Validation error. Quantity must be a whole number. Product not saved. |

### TC-VAL-016: Product Name - Empty
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter valid SKU<br>2. Leave Product Name empty<br>3. Click Save |
| **Expected Result** | MsgBox "Product Name is required." Product not saved. Focus on Product Name field. |

### TC-VAL-017: Category - None Selected
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter valid SKU and Name<br>2. Do not select any category<br>3. Click Save |
| **Expected Result** | MsgBox "Please select a category." Product not saved. |

### TC-VAL-018: Reorder Level - Valid Range
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Enter Reorder Level: "50"<br>2. Fill other valid fields<br>3. Click Save |
| **Expected Result** | Validation passes. Product saved with reorder level 50. |

### TC-VAL-019: All Fields Empty
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | frmProduct open in Add mode. |
| **Steps** | 1. Leave all fields empty<br>2. Click Save |
| **Expected Result** | Validation error for first empty required field (SKU). Product not saved. |

---

## 7. Low Stock Alert Tests

### TC-LOWSTOCK-001: Low Stock Highlighting
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. Seed data loaded. |
| **Steps** | 1. Examine the ListView on frmMain |
| **Expected Result** | Products with Qty <= Reorder Level are displayed with orange-colored text. Expected: USB-C Hub (8 <= 15), Denim Jeans (5 <= 20), Green Tea Box (0 <= 25), Ergonomic Chair (3 <= 5), First Aid Kit (10 <= 10). |

### TC-LOWSTOCK-002: Out of Stock Highlighting
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. Seed data loaded. |
| **Steps** | 1. Examine "Green Tea Box" in the ListView |
| **Expected Result** | Green Tea Box (Qty = 0) shown with red text. Status column shows "Out of Stock". |

### TC-LOWSTOCK-003: Normal Stock Display
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. Seed data loaded. |
| **Steps** | 1. Examine "Wireless Mouse" in the ListView (Qty 150, Reorder 25) |
| **Expected Result** | Displayed with default text color. Status column shows "OK". |

### TC-LOWSTOCK-004: Status Bar Low Stock Count
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. Seed data loaded. |
| **Steps** | 1. Check status bar at bottom of frmMain |
| **Expected Result** | "Low Stock: 5" displayed (USB-C Hub, Denim Jeans, Green Tea Box, Ergonomic Chair, First Aid Kit). |

### TC-LOWSTOCK-005: Low Stock After Edit
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. Wireless Mouse has Qty=150, Reorder=25. |
| **Steps** | 1. Select Wireless Mouse<br>2. Click Edit<br>3. Change Quantity to "10"<br>4. Click Save |
| **Expected Result** | After save, Wireless Mouse now shows with orange text. Status = "Low Stock". Low stock count in status bar increments. |

---

## 8. Dashboard and UI Tests

### TC-UI-001: Initial Product Load
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. First load of frmMain. |
| **Steps** | 1. Observe the ListView after login |
| **Expected Result** | ListView displays all 10 seed products. All 9 columns visible (ID, SKU, Name, Category, Price, Qty, Reorder Lvl, Total Value, Status). Status bar shows correct counts. |

### TC-UI-002: ListView Column Data
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Logged in. Seed data loaded. |
| **Steps** | 1. Verify first product row (Wireless Mouse) |
| **Expected Result** | ID: 1, SKU: ELC-1001-0001, Name: Wireless Mouse, Category: Electronics, Price: $29.99, Qty: 150, Reorder Lvl: 25, Total Value: $4,498.50, Status: OK. |

### TC-UI-003: Refresh Button
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in. Search/filter active. |
| **Steps** | 1. Perform a search that filters results<br>2. Click Refresh button |
| **Expected Result** | Search field cleared. Category reset to "(All)". ListView shows all products. Status bar updated. |

### TC-UI-004: Status Bar Information
| Field | Value |
|-------|-------|
| **Priority** | Medium |
| **Precondition** | Logged in as admin. |
| **Steps** | 1. Verify status bar panels |
| **Expected Result** | Panel 1: "User: System Administrator (Admin)". Panel 2: "Products: 10". Panel 3: "Low Stock: 5". Panel 4: "Value: [total value]". |

### TC-UI-005: About Dialog
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Logged in. frmMain displayed. |
| **Steps** | 1. Click Help > About menu |
| **Expected Result** | frmAbout opens as modal dialog. Shows: App name, Version 1.0.0, Description, Developer, Copyright. OK button closes the dialog. |

### TC-UI-006: Form Resize
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Logged in. frmMain displayed. |
| **Steps** | 1. Resize frmMain window |
| **Expected Result** | ListView resizes to fill available space. Status bar remains at bottom. No controls overlap or disappear. |

### TC-UI-007: Menu Keyboard Shortcuts
| Field | Value |
|-------|-------|
| **Priority** | Low |
| **Precondition** | Logged in. frmMain displayed. |
| **Steps** | 1. Press Alt+F to open File menu<br>2. Press Alt+P to open Products menu<br>3. Press Alt+R to open Reports menu<br>4. Press Alt+H to open Help menu |
| **Expected Result** | Each menu opens correctly with keyboard shortcut. Menu items accessible via keyboard. |

---

## 9. Seed Data Verification Tests

### TC-SEED-001: Verify 10 Products Loaded
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application freshly launched. Logged in. |
| **Steps** | 1. Count products in ListView |
| **Expected Result** | Exactly 10 products displayed. Status bar shows "Products: 10". |

### TC-SEED-002: Verify Product Data Accuracy
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application freshly launched. Logged in. |
| **Steps** | 1. Verify each of the 10 seed products against expected data |
| **Expected Result** | All products match seed data: (1) Wireless Mouse - Electronics $29.99/150, (2) USB-C Hub - Electronics $49.99/8, (3) Cotton T-Shirt - Clothing $19.99/200, (4) Denim Jeans - Clothing $45.99/5, (5) Organic Coffee Beans - Food $12.99/300, (6) Green Tea Box - Food $8.99/0, (7) Office Desk - Furniture $299.99/12, (8) Ergonomic Chair - Furniture $449.99/3, (9) A4 Paper Ream - Office Supplies $5.99/500, (10) First Aid Kit - Other $24.99/10. |

### TC-SEED-003: Verify 3 Demo Users
| Field | Value |
|-------|-------|
| **Priority** | High |
| **Precondition** | Application freshly launched. |
| **Steps** | 1. Login with admin/admin123 → Verify Admin role<br>2. Restart, login with manager/manager123 → Verify Manager role<br>3. Restart, login with clerk/clerk123 → Verify Supervisor role |
| **Expected Result** | All 3 users authenticate successfully with correct roles: admin = Admin, manager = Manager, clerk = Supervisor. |

---

## 10. Test Summary

| Category | Total Tests | Critical | High | Medium | Low |
|----------|-------------|----------|------|--------|-----|
| Login | 11 | 1 | 4 | 4 | 2 |
| CRUD | 8 | 3 | 2 | 3 | 0 |
| RBAC | 5 | 3 | 0 | 2 | 0 |
| Search/Filter | 8 | 0 | 3 | 5 | 0 |
| Reports | 7 | 0 | 5 | 0 | 2 |
| Validation | 19 | 0 | 11 | 6 | 0 |
| Low Stock | 5 | 0 | 2 | 3 | 0 |
| Dashboard/UI | 7 | 1 | 1 | 2 | 3 |
| Seed Data | 3 | 0 | 3 | 0 | 0 |
| **Total** | **73** | **8** | **31** | **25** | **7** |
