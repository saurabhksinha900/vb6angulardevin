# VB6 Inventory Management System - Requirements Document

## 1. Project Overview

**Project Name:** VB6 Inventory Management System  
**Platform:** Visual Basic 6.0 (VB6)  
**Database:** In-memory Microsoft Jet 4.0 (ADO)  
**Version:** 1.0  

The Inventory Management System is a desktop application built in Visual Basic 6.0 that enables users to manage product inventory with role-based access control. The system provides product CRUD operations, search/filter capabilities, low stock alerts, and reporting functionality.

---

## 2. Authentication & Security

### 2.1 Login Form
- The application launches with a login form (`frmLogin`).
- Users must enter a **username** and **password** to access the system.
- Passwords are stored as hashed values (simple hash function for demo purposes).
- The login form displays the application title and version.

### 2.2 Login Attempt Lockout
- Users are allowed a maximum of **3 consecutive failed login attempts**.
- After 3 failed attempts, the application displays a lockout message and **terminates**.
- The failed attempt counter resets on successful login.
- Each failed attempt displays a warning indicating the number of remaining attempts.

### 2.3 Demo Users
The system is pre-seeded with the following demo accounts:

| Username | Password    | Role       |
|----------|-------------|------------|
| admin    | admin123    | Admin      |
| manager  | manager123  | Manager    |
| clerk    | clerk123    | Supervisor |

---

## 3. Role-Based Access Control (RBAC)

### 3.1 Roles and Permissions

| Feature                | Admin | Manager | Supervisor |
|------------------------|-------|---------|------------|
| View Dashboard         | Yes   | Yes     | Yes        |
| Search/Filter Products | Yes   | Yes     | Yes        |
| Add Product            | Yes   | Yes     | No         |
| Edit Product           | Yes   | Yes     | No         |
| Delete Product         | Yes   | No      | No         |
| Generate Reports       | Yes   | Yes     | Yes        |
| Export Reports          | Yes   | Yes     | Yes        |
| View About Dialog      | Yes   | Yes     | Yes        |

### 3.2 UI Enforcement
- Buttons and menu items for unauthorized actions are **disabled** (not hidden) for restricted roles.
- The status bar displays the currently logged-in user's name and role.

---

## 4. Main Dashboard (frmMain)

### 4.1 Layout
- **Menu Bar** with menus: File (Exit), Products (Add, Edit, Delete), Reports (Generate), Help (About)
- **Toolbar** with buttons: Add Product, Edit Product, Delete Product, Generate Report, Refresh
- **Search Panel** with:
  - Text input for product name search
  - Dropdown for category filter
  - Search button
  - Clear/Reset button
- **Product ListView** (main content area) displaying all products
- **Status Bar** showing: logged-in user, role, total products count, total inventory value

### 4.2 Product ListView Columns

| Column        | Description                                    |
|---------------|------------------------------------------------|
| ID            | Auto-generated unique product identifier       |
| SKU           | Stock Keeping Unit (format: XXX-XXXX-XXXX)     |
| Name          | Product name                                   |
| Category      | Product category                               |
| Price         | Unit price (formatted as currency)             |
| Quantity      | Current stock quantity                         |
| Reorder Level | Minimum stock threshold                        |
| Total Value   | Calculated: Price x Quantity                   |
| Status        | "OK", "Low Stock", or "Out of Stock"           |

### 4.3 Low Stock Alerts
- Products where **Quantity <= Reorder Level** are highlighted with an **orange background** in the ListView.
- Products where **Quantity = 0** are marked as "Out of Stock".
- A summary count of low stock items is displayed in the status bar.

### 4.4 Data Refresh
- The ListView refreshes automatically after any CRUD operation.
- A manual Refresh button is available on the toolbar.

---

## 5. Product CRUD Form (frmProduct)

### 5.1 Form Fields

| Field         | Type     | Validation                                          |
|---------------|----------|-----------------------------------------------------|
| SKU           | TextBox  | Format: XXX-XXXX-XXXX (letters/digits, with dashes) |
| Product Name  | TextBox  | Required, 1-100 characters                          |
| Category      | ComboBox | Required, select from predefined list                |
| Price         | TextBox  | Numeric, range: $0.01 - $999,999.99                 |
| Quantity      | TextBox  | Integer, range: 0 - 999,999                         |
| Reorder Level | TextBox  | Integer, range: 0 - 999,999                         |

### 5.2 Categories
The following categories are available:
1. Electronics
2. Clothing
3. Food
4. Furniture
5. Office Supplies
6. Other

### 5.3 Add Product
- Opens `frmProduct` in **Add mode** with empty fields.
- SKU field receives focus.
- All fields are validated on Save.
- On successful save, a confirmation message is displayed, and the dashboard refreshes.

### 5.4 Edit Product
- User must select a product in the ListView first.
- Opens `frmProduct` in **Edit mode** with fields pre-populated.
- SKU field is **read-only** during edit.
- Product ID is not editable.
- On successful save, a confirmation message is displayed, and the dashboard refreshes.

### 5.5 Delete Product
- User must select a product in the ListView first.
- Displays a **confirmation dialog** before deletion (Yes/No).
- On successful deletion, a confirmation message is displayed, and the dashboard refreshes.
- Only Admin role can delete products.

### 5.6 Validation Rules
- All required fields must be filled before saving.
- SKU must match the pattern: `XXX-XXXX-XXXX` (3 chars, dash, 4 chars, dash, 4 chars; alphanumeric).
- SKU must be unique across all products (checked on Add).
- Price must be a valid decimal number between $0.01 and $999,999.99.
- Quantity must be a whole number between 0 and 999,999.
- Reorder Level must be a whole number between 0 and 999,999.
- Validation errors are displayed with descriptive messages using MsgBox.

---

## 6. Search and Filter

### 6.1 Search by Product Name
- Partial, case-insensitive text search.
- Filters the ListView to show only matching products.
- Search executes on button click.

### 6.2 Filter by Category
- Dropdown with options: (All), Electronics, Clothing, Food, Furniture, Office Supplies, Other.
- Default selection is "(All)" showing all categories.
- Category filter can be combined with the name search.

### 6.3 Clear/Reset
- Clears the search text and resets the category filter to "(All)".
- Restores the ListView to show all products.

---

## 7. Reports Form (frmReport)

### 7.1 Report Types

#### 7.1.1 Summary Report
- Total number of products
- Total inventory value (sum of Price x Quantity for all products)
- Average product price
- Total quantity in stock
- Number of categories with products

#### 7.1.2 By Category Report
- Grouped by category
- For each category: product count, total value, average price
- Sorted by category name

#### 7.1.3 Low Stock Alert Report
- Lists all products where Quantity <= Reorder Level
- Columns: SKU, Name, Category, Current Qty, Reorder Level, Shortage (Reorder Level - Quantity)
- Sorted by shortage (most critical first)

#### 7.1.4 Inventory Value Report
- Lists all products sorted by total value (Price x Quantity) descending
- Columns: SKU, Name, Price, Quantity, Total Value
- Grand total at the bottom

### 7.2 Report Display
- Reports are displayed in a **TextBox** (multiline, read-only) within the form.
- Report type is selected via **OptionButtons** (radio buttons).
- A "Generate" button produces the selected report.

### 7.3 Export to Text File
- An "Export" button saves the currently displayed report to a **.txt** file.
- Uses a **CommonDialog** (Save As) to let the user choose the file location and name.
- Default filename format: `Report_[Type]_[Date].txt`

---

## 8. About Dialog (frmAbout)

- **Application Name:** VB6 Inventory Management System
- **Version:** 1.0.0
- **Description:** A comprehensive inventory management solution built with Visual Basic 6.0
- **Developer:** VB6 Development Team
- **Copyright:** 2024
- An "OK" button to close the dialog.
- Modal dialog (cannot interact with parent form while open).

---

## 9. Database Layer

### 9.1 Technology
- **ADO (ActiveX Data Objects)** with **Microsoft Jet 4.0 OLE DB Provider**
- In-memory database (no external database file required)
- Connection string uses Jet 4.0 provider

### 9.2 Product Table Schema

| Field        | Type          | Constraints                |
|--------------|---------------|----------------------------|
| ProductID    | AutoNumber    | Primary Key                |
| SKU          | Text(15)      | Unique, Not Null           |
| ProductName  | Text(100)     | Not Null                   |
| Category     | Text(50)      | Not Null                   |
| Price        | Currency      | Not Null, > 0              |
| Quantity     | Integer       | Not Null, >= 0             |
| ReorderLevel | Integer       | Not Null, >= 0             |

### 9.3 User Table Schema

| Field        | Type          | Constraints                |
|--------------|---------------|----------------------------|
| UserID       | AutoNumber    | Primary Key                |
| Username     | Text(50)      | Unique, Not Null           |
| PasswordHash | Text(255)     | Not Null                   |
| Role         | Text(20)      | Not Null                   |
| FullName     | Text(100)     | Not Null                   |

### 9.4 Seed Data - Products
The system initializes with 10 pre-seeded products:

| # | SKU            | Name                    | Category         | Price    | Qty  | Reorder |
|---|----------------|-------------------------|------------------|----------|------|---------|
| 1 | ELC-1001-0001  | Wireless Mouse          | Electronics      | $29.99   | 150  | 25      |
| 2 | ELC-1002-0002  | USB-C Hub               | Electronics      | $49.99   | 8    | 15      |
| 3 | CLT-2001-0001  | Cotton T-Shirt          | Clothing         | $19.99   | 200  | 30      |
| 4 | CLT-2002-0002  | Denim Jeans             | Clothing         | $45.99   | 5    | 20      |
| 5 | FOD-3001-0001  | Organic Coffee Beans    | Food             | $12.99   | 300  | 50      |
| 6 | FOD-3002-0002  | Green Tea Box           | Food             | $8.99    | 0    | 25      |
| 7 | FRN-4001-0001  | Office Desk             | Furniture        | $299.99  | 12   | 5       |
| 8 | FRN-4002-0002  | Ergonomic Chair         | Furniture        | $449.99  | 3    | 5       |
| 9 | OFS-5001-0001  | A4 Paper Ream           | Office Supplies  | $5.99    | 500  | 100     |
| 10| OTH-6001-0001  | First Aid Kit           | Other            | $24.99   | 10   | 10      |

### 9.5 Seed Data - Users

| Username | Password (plain) | Password (hashed) | Role       | Full Name          |
|----------|------------------|--------------------|------------|--------------------|
| admin    | admin123         | (hash of admin123) | Admin      | System Administrator |
| manager  | manager123       | (hash of manager123)| Manager   | Store Manager       |
| clerk    | clerk123         | (hash of clerk123) | Supervisor | Store Clerk         |

---

## 10. Modules

### 10.1 Constants Module (modConstants)
Defines application-wide constants:
- Application name, version
- Database connection settings
- Maximum login attempts (3)
- SKU format pattern
- Price range limits (min: 0.01, max: 999999.99)
- Quantity range limits (min: 0, max: 999999)
- Category list
- Role names (Admin, Manager, Supervisor)
- Status strings ("OK", "Low Stock", "Out of Stock")

### 10.2 Database Module (modDatabase)
Handles all database operations:
- Initialize/create in-memory database
- Create tables (Products, Users)
- Seed initial data
- CRUD operations for products
- User authentication queries
- Search and filter queries
- Report data queries
- Connection management (open/close)

### 10.3 Utilities Module (modUtilities)
Provides helper functions:
- **Validation:** SKU format validation, price range check, quantity range check, required field check
- **Hashing:** Simple password hash function for demo security
- **Currency Formatting:** Format numbers as currency strings
- **Logging:** Write log entries to a log file with timestamps
- **String Helpers:** Pad strings, truncate strings, safe string conversion
- **Date Formatting:** Standard date/time formatting for reports

---

## 11. Non-Functional Requirements

### 11.1 Performance
- Application should load within 2 seconds.
- ListView should render up to 1,000 products without noticeable lag.
- Reports should generate within 1 second.

### 11.2 Usability
- Consistent UI layout across all forms.
- Keyboard navigation support (Tab order set for all forms).
- Descriptive error messages for validation failures.
- Confirmation dialogs before destructive operations (delete).

### 11.3 Compatibility
- Targets VB6 runtime (msvbvm60.dll).
- Uses standard VB6 controls (no third-party OCX dependencies beyond Microsoft Common Controls 6.0).
- References: Microsoft ADO 2.8, Microsoft Jet 4.0 OLE DB Provider, Microsoft Common Dialog Control.

### 11.4 Error Handling
- All database operations wrapped in error handlers.
- User-friendly error messages (no raw error codes shown to users).
- Critical errors logged to application log file.

---

## 12. Glossary

| Term          | Definition                                                     |
|---------------|----------------------------------------------------------------|
| SKU           | Stock Keeping Unit - unique product identifier                 |
| RBAC          | Role-Based Access Control                                      |
| CRUD          | Create, Read, Update, Delete                                   |
| ADO           | ActiveX Data Objects - database access technology              |
| Jet 4.0       | Microsoft Jet Database Engine                                  |
| Reorder Level | Minimum stock quantity before restocking is needed             |
| Low Stock     | Condition where current quantity is at or below reorder level  |
