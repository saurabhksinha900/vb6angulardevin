# VB6 Inventory Management System - Design Document

## 1. Project Structure

```
InventoryManager/
├── InventoryManager.vbp          ' VB6 Project File
├── Forms/
│   ├── frmLogin.frm              ' Login Form
│   ├── frmMain.frm               ' Main Dashboard Form
│   ├── frmProduct.frm            ' Product Add/Edit Form
│   ├── frmReport.frm             ' Reports Form
│   └── frmAbout.frm              ' About Dialog
├── Modules/
│   ├── modConstants.bas           ' Application Constants
│   ├── modDatabase.bas            ' Database Layer
│   └── modUtilities.bas           ' Utility Functions
└── Classes/
    ├── clsProduct.cls             ' Product Business Object
    ├── clsInventory.cls           ' Inventory Manager Class
    └── clsUser.cls                ' User/Auth Class
```

---

## 2. Data Model

### 2.1 Category Enumeration

```vb
Public Enum ProductCategory
    catElectronics = 1
    catClothing = 2
    catFood = 3
    catFurniture = 4
    catOfficeSupplies = 5
    catOther = 6
End Enum
```

### 2.2 Role Enumeration

```vb
Public Enum UserRole
    roleAdmin = 1
    roleManager = 2
    roleSupervisor = 3
End Enum
```

### 2.3 Product Fields

| Field        | VB6 Type | DB Type       | Description                        |
|--------------|----------|---------------|------------------------------------|
| ProductID    | Long     | AutoNumber    | Auto-generated primary key         |
| SKU          | String   | Text(15)      | Unique stock keeping unit          |
| ProductName  | String   | Text(100)     | Name of the product                |
| Category     | String   | Text(50)      | Product category name              |
| Price        | Currency | Currency      | Unit price                         |
| Quantity     | Long     | Integer       | Current stock quantity             |
| ReorderLevel | Long     | Integer       | Minimum stock threshold            |

**Computed Fields (not stored):**
- TotalValue: Currency = Price * Quantity
- Status: String = "OK" | "Low Stock" | "Out of Stock"

### 2.4 User Fields

| Field        | VB6 Type | DB Type       | Description                        |
|--------------|----------|---------------|------------------------------------|
| UserID       | Long     | AutoNumber    | Auto-generated primary key         |
| Username     | String   | Text(50)      | Unique login username              |
| PasswordHash | String   | Text(255)     | Hashed password                    |
| Role         | String   | Text(20)      | Role name (Admin/Manager/Supervisor)|
| FullName     | String   | Text(100)     | Display name                       |

---

## 3. UI Wireframes

### 3.1 frmLogin

```
+=============================================+
|        VB6 Inventory Management System      |
|=============================================|
|                                             |
|         [App Logo / Title Image]            |
|                                             |
|    Username: [________________________]     |
|                                             |
|    Password: [________________________]     |
|                                             |
|         [  Login  ]    [  Exit  ]           |
|                                             |
|    Status: Ready                            |
+=============================================+
```

**Properties:**
- Form: BorderStyle = Fixed Dialog, StartUpPosition = Center
- txtUsername: MaxLength = 50
- txtPassword: MaxLength = 50, PasswordChar = "*"
- cmdLogin: Default = True
- cmdExit: Cancel = True
- lblStatus: Shows login feedback messages

### 3.2 frmMain

```
+================================================================+
| File | Products | Reports | Help |                              |
|================================================================|
| [Add] [Edit] [Delete] [Report] [Refresh]          Toolbar      |
|================================================================|
| Search: [_______________] Category: [All_______v] [Search][Clear]
|================================================================|
| ID | SKU          | Name         | Category    | Price  | Qty  |
|    |              |              |             |        |      |
|    | Reorder Lvl  | Total Value  | Status      |        |      |
|----|--------------|--------------|-------------|--------|------|
| 1  | ELC-1001-0001| Wireless Mou | Electronics | $29.99 | 150  |
|    | 25           | $4,498.50    | OK          |        |      |
|----|--------------|--------------|-------------|--------|------|
| 2  | ELC-1002-0002| USB-C Hub    | Electronics | $49.99 | 8    |
|    | 15           | $399.92      | Low Stock   |        |      |
|----|--------------|--------------|-------------|--------|------|
| ...                                                            |
|================================================================|
| User: admin (Admin) | Products: 10 | Low Stock: 4 | Value: $X  |
+================================================================+
```

**Properties:**
- Form: BorderStyle = Sizable, WindowState = Maximized, StartUpPosition = Center
- mnuFile: &File -> mnuFileExit: E&xit
- mnuProducts: &Products -> mnuProductAdd: &Add, mnuProductEdit: &Edit, mnuProductDelete: &Delete
- mnuReports: &Reports -> mnuReportGenerate: &Generate Report
- mnuHelp: &Help -> mnuHelpAbout: &About
- tlbMain: Toolbar with ImageList icons
- lvwProducts: ListView, View = lvwReport, FullRowSelect = True, GridLines = True
- txtSearch: Text input for name search
- cboCategory: Dropdown for category filter
- cmdSearch, cmdClear: Action buttons
- staMain: StatusBar with 4 panels

### 3.3 frmProduct

```
+=============================================+
|  Add Product  /  Edit Product               |
|=============================================|
|                                             |
|  SKU:          [___-____-____]              |
|                (Format: XXX-XXXX-XXXX)      |
|                                             |
|  Product Name: [________________________]   |
|                                             |
|  Category:     [Electronics________v]       |
|                                             |
|  Price ($):    [________________]           |
|                ($0.01 - $999,999.99)        |
|                                             |
|  Quantity:     [________________]           |
|                (0 - 999,999)               |
|                                             |
|  Reorder Level:[________________]           |
|                (0 - 999,999)               |
|                                             |
|         [  Save  ]    [  Cancel  ]          |
+=============================================+
```

**Properties:**
- Form: BorderStyle = Fixed Dialog, StartUpPosition = Center
- txtSKU: MaxLength = 14
- txtProductName: MaxLength = 100
- cboCategory: Style = Dropdown List
- txtPrice: Alignment = Right
- txtQuantity: Alignment = Right
- txtReorderLevel: Alignment = Right
- cmdSave: Default = True
- cmdCancel: Cancel = True

### 3.4 frmReport

```
+=============================================+
|  Inventory Reports                          |
|=============================================|
|                                             |
|  Report Type:                               |
|  (o) Summary Report                        |
|  ( ) By Category Report                    |
|  ( ) Low Stock Alert Report                |
|  ( ) Inventory Value Report                |
|                                             |
|  [  Generate  ]                             |
|                                             |
|  +---------------------------------------+ |
|  | Report Output:                        | |
|  |                                       | |
|  | Inventory Summary Report              | |
|  | Generated: 2024-01-15 10:30:00        | |
|  | ===================================== | |
|  | Total Products: 10                    | |
|  | Total Value: $45,678.90              | |
|  | Average Price: $94.79                | |
|  | ...                                   | |
|  +---------------------------------------+ |
|                                             |
|  [  Export  ]    [  Close  ]                |
+=============================================+
```

**Properties:**
- Form: BorderStyle = Fixed Dialog, StartUpPosition = Center, Width = 8000, Height = 8000
- fraReportType: Frame containing OptionButtons
- optSummary, optByCategory, optLowStock, optValue: OptionButtons
- cmdGenerate: Generates selected report
- txtReport: MultiLine = True, ScrollBars = Vertical, Locked = True
- cmdExport: Saves report to text file
- cmdClose: Cancel = True
- dlgSave: CommonDialog for Save As

### 3.5 frmAbout

```
+=============================================+
|  About                                      |
|=============================================|
|                                             |
|     VB6 Inventory Management System         |
|                                             |
|     Version: 1.0.0                          |
|                                             |
|     A comprehensive inventory management    |
|     solution built with Visual Basic 6.0    |
|                                             |
|     Developer: VB6 Development Team         |
|     Copyright (c) 2024                      |
|                                             |
|              [   OK   ]                     |
+=============================================+
```

**Properties:**
- Form: BorderStyle = Fixed Dialog, StartUpPosition = Center
- lblAppName: Font = Bold, 14pt
- lblVersion, lblDescription, lblDeveloper, lblCopyright: Info labels
- cmdOK: Default = True, Cancel = True

---

## 4. Module Method Signatures

### 4.1 modConstants.bas

```vb
' Application Info
Public Const APP_NAME As String = "VB6 Inventory Management System"
Public Const APP_VERSION As String = "1.0.0"

' Database
Public Const DB_PROVIDER As String = "Microsoft.Jet.OLEDB.4.0"
Public Const DB_SOURCE As String = ""  ' In-memory

' Login
Public Const MAX_LOGIN_ATTEMPTS As Integer = 3

' Validation
Public Const SKU_PATTERN As String = "^[A-Za-z0-9]{3}-[A-Za-z0-9]{4}-[A-Za-z0-9]{4}$"
Public Const PRICE_MIN As Currency = 0.01
Public Const PRICE_MAX As Currency = 999999.99
Public Const QTY_MIN As Long = 0
Public Const QTY_MAX As Long = 999999

' Categories
Public Const CAT_ELECTRONICS As String = "Electronics"
Public Const CAT_CLOTHING As String = "Clothing"
Public Const CAT_FOOD As String = "Food"
Public Const CAT_FURNITURE As String = "Furniture"
Public Const CAT_OFFICE_SUPPLIES As String = "Office Supplies"
Public Const CAT_OTHER As String = "Other"

' Roles
Public Const ROLE_ADMIN As String = "Admin"
Public Const ROLE_MANAGER As String = "Manager"
Public Const ROLE_SUPERVISOR As String = "Supervisor"

' Status
Public Const STATUS_OK As String = "OK"
Public Const STATUS_LOW_STOCK As String = "Low Stock"
Public Const STATUS_OUT_OF_STOCK As String = "Out of Stock"
```

### 4.2 modDatabase.bas

```vb
' Connection Management
Public Sub InitializeDatabase()
    ' Creates in-memory DB, tables, and seeds data

Public Sub OpenConnection()
    ' Opens ADO connection to Jet 4.0

Public Sub CloseConnection()
    ' Closes ADO connection

' User Operations
Public Function AuthenticateUser(ByVal Username As String, ByVal PasswordHash As String) As ADODB.Recordset
    ' Returns user recordset if credentials match, Nothing otherwise

' Product CRUD
Public Function GetAllProducts() As ADODB.Recordset
    ' Returns all products ordered by ProductID

Public Function GetProductByID(ByVal ProductID As Long) As ADODB.Recordset
    ' Returns single product by ID

Public Function GetProductBySKU(ByVal SKU As String) As ADODB.Recordset
    ' Returns single product by SKU

Public Function AddProduct(ByVal SKU As String, ByVal ProductName As String, _
    ByVal Category As String, ByVal Price As Currency, _
    ByVal Quantity As Long, ByVal ReorderLevel As Long) As Boolean
    ' Inserts new product, returns True on success

Public Function UpdateProduct(ByVal ProductID As Long, ByVal ProductName As String, _
    ByVal Category As String, ByVal Price As Currency, _
    ByVal Quantity As Long, ByVal ReorderLevel As Long) As Boolean
    ' Updates existing product, returns True on success

Public Function DeleteProduct(ByVal ProductID As Long) As Boolean
    ' Deletes product by ID, returns True on success

' Search/Filter
Public Function SearchProducts(ByVal SearchName As String, ByVal FilterCategory As String) As ADODB.Recordset
    ' Returns filtered product recordset

' Report Queries
Public Function GetProductCount() As Long
Public Function GetTotalInventoryValue() As Currency
Public Function GetAveragePrice() As Currency
Public Function GetTotalQuantity() As Long
Public Function GetCategoryCount() As Long
Public Function GetProductsByCategory() As ADODB.Recordset
Public Function GetLowStockProducts() As ADODB.Recordset
Public Function GetProductsByValue() As ADODB.Recordset

' Seed Data
Private Sub CreateTables()
    ' Creates Products and Users tables

Private Sub SeedProducts()
    ' Inserts 10 default products

Private Sub SeedUsers()
    ' Inserts 3 default users (admin, manager, clerk)
```

### 4.3 modUtilities.bas

```vb
' Validation
Public Function IsValidSKU(ByVal SKU As String) As Boolean
    ' Validates SKU format: XXX-XXXX-XXXX

Public Function IsValidPrice(ByVal Price As String) As Boolean
    ' Validates price is numeric and within range

Public Function IsValidQuantity(ByVal Qty As String) As Boolean
    ' Validates quantity is integer and within range

Public Function IsRequiredField(ByVal Value As String) As Boolean
    ' Checks if field is not empty/whitespace

' Hashing
Public Function HashPassword(ByVal Password As String) As String
    ' Simple hash function for demo password security

' Formatting
Public Function FormatAsCurrency(ByVal Amount As Currency) As String
    ' Formats number as $X,XXX.XX

Public Function FormatAsInteger(ByVal Value As Long) As String
    ' Formats number with thousand separators

Public Function PadString(ByVal Text As String, ByVal Length As Long, _
    Optional ByVal PadChar As String = " ") As String
    ' Pads string to fixed length

Public Function TruncateString(ByVal Text As String, ByVal MaxLength As Long) As String
    ' Truncates string with ellipsis if too long

' Logging
Public Sub LogMessage(ByVal Message As String)
    ' Writes timestamped message to log file

Public Sub LogError(ByVal Source As String, ByVal ErrNumber As Long, ByVal ErrDescription As String)
    ' Writes error details to log file

' Date/Time
Public Function FormatDateTime_Custom(ByVal dt As Date) As String
    ' Returns formatted date/time string: YYYY-MM-DD HH:MM:SS

Public Function FormatDate_Custom(ByVal dt As Date) As String
    ' Returns formatted date string: YYYY-MM-DD

' String Helpers
Public Function SafeString(ByVal Value As Variant) As String
    ' Safely converts Variant to String, handles Null

Public Function SafeLong(ByVal Value As Variant) As Long
    ' Safely converts Variant to Long, handles Null

Public Function SafeCurrency(ByVal Value As Variant) As Currency
    ' Safely converts Variant to Currency, handles Null

' Product Status
Public Function GetProductStatus(ByVal Quantity As Long, ByVal ReorderLevel As Long) As String
    ' Returns "OK", "Low Stock", or "Out of Stock"
```

---

## 5. Class Method Signatures

### 5.1 clsProduct.cls

```vb
' Properties
Public Property Get ProductID() As Long
Public Property Let ProductID(ByVal Value As Long)

Public Property Get SKU() As String
Public Property Let SKU(ByVal Value As String)

Public Property Get ProductName() As String
Public Property Let ProductName(ByVal Value As String)

Public Property Get Category() As String
Public Property Let Category(ByVal Value As String)

Public Property Get Price() As Currency
Public Property Let Price(ByVal Value As Currency)

Public Property Get Quantity() As Long
Public Property Let Quantity(ByVal Value As Long)

Public Property Get ReorderLevel() As Long
Public Property Let ReorderLevel(ByVal Value As Long)

' Computed Properties
Public Property Get TotalValue() As Currency
    ' Returns Price * Quantity

Public Property Get Status() As String
    ' Returns "OK", "Low Stock", or "Out of Stock"

Public Property Get IsLowStock() As Boolean
    ' Returns True if Quantity <= ReorderLevel

Public Property Get IsOutOfStock() As Boolean
    ' Returns True if Quantity = 0

' Methods
Public Function Validate() As String
    ' Validates all fields, returns empty string if valid, error message if not

Public Sub LoadFromRecordset(ByVal rs As ADODB.Recordset)
    ' Populates properties from ADO recordset row

Public Sub Clear()
    ' Resets all properties to defaults
```

### 5.2 clsInventory.cls

```vb
' Product Operations
Public Function GetAllProducts() As Collection
    ' Returns Collection of clsProduct objects

Public Function GetProductByID(ByVal ProductID As Long) As clsProduct
    ' Returns single clsProduct or Nothing

Public Function AddProduct(ByVal Product As clsProduct) As Boolean
    ' Validates and adds product to database

Public Function UpdateProduct(ByVal Product As clsProduct) As Boolean
    ' Validates and updates product in database

Public Function DeleteProduct(ByVal ProductID As Long) As Boolean
    ' Deletes product from database

' Search/Filter
Public Function SearchProducts(ByVal SearchName As String, ByVal FilterCategory As String) As Collection
    ' Returns filtered Collection of clsProduct objects

' Reporting
Public Function GetSummaryReport() As String
    ' Generates summary report text

Public Function GetCategoryReport() As String
    ' Generates by-category report text

Public Function GetLowStockReport() As String
    ' Generates low stock alert report text

Public Function GetValueReport() As String
    ' Generates inventory value report text

' Statistics
Public Function GetProductCount() As Long
Public Function GetTotalValue() As Currency
Public Function GetLowStockCount() As Long
```

### 5.3 clsUser.cls

```vb
' Properties
Public Property Get UserID() As Long
Public Property Let UserID(ByVal Value As Long)

Public Property Get Username() As String
Public Property Let Username(ByVal Value As String)

Public Property Get Role() As String
Public Property Let Role(ByVal Value As String)

Public Property Get FullName() As String
Public Property Let FullName(ByVal Value As String)

' Permission Checks
Public Property Get CanAddProduct() As Boolean
    ' Returns True for Admin and Manager

Public Property Get CanEditProduct() As Boolean
    ' Returns True for Admin and Manager

Public Property Get CanDeleteProduct() As Boolean
    ' Returns True for Admin only

Public Property Get CanGenerateReports() As Boolean
    ' Returns True for all roles

Public Property Get CanExportReports() As Boolean
    ' Returns True for all roles

' Methods
Public Function Authenticate(ByVal Username As String, ByVal Password As String) As Boolean
    ' Authenticates user against database, populates properties on success

Public Sub LoadFromRecordset(ByVal rs As ADODB.Recordset)
    ' Populates properties from ADO recordset row

Public Sub Clear()
    ' Resets all properties / logs out
```

---

## 6. Form Event Flow

### 6.1 Application Startup
1. `Sub Main()` in modDatabase initializes the database
2. `frmLogin.Show vbModal` displays the login form
3. On successful login, `frmMain.Show` displays the dashboard
4. On login failure (3 attempts), application terminates

### 6.2 frmLogin Event Flow
```
Form_Load -> Initialize controls, set focus to txtUsername
cmdLogin_Click -> Validate inputs -> AuthenticateUser -> 
    Success: Store user in global, Unload frmLogin, Show frmMain
    Failure: Increment attempt counter -> Show warning -> 
        If 3 attempts: Show lockout msg -> End
cmdExit_Click -> End
```

### 6.3 frmMain Event Flow
```
Form_Load -> Apply RBAC (enable/disable controls) -> LoadProducts -> UpdateStatusBar
lvwProducts_ItemClick -> Store selected ProductID
cmdAdd_Click / mnuProductAdd_Click -> Open frmProduct in Add mode
cmdEdit_Click / mnuProductEdit_Click -> Validate selection -> Open frmProduct in Edit mode
cmdDelete_Click / mnuProductDelete_Click -> Validate selection -> Confirm -> Delete -> Refresh
cmdReport_Click / mnuReportGenerate_Click -> Open frmReport
cmdRefresh_Click -> LoadProducts -> UpdateStatusBar
cmdSearch_Click -> SearchProducts with current filters
cmdClear_Click -> Reset search/filter -> LoadProducts
mnuFileExit_Click -> Unload Me
mnuHelpAbout_Click -> Open frmAbout
Form_Unload -> CloseConnection -> End
```

### 6.4 frmProduct Event Flow
```
Form_Load -> Populate category dropdown -> 
    If Edit mode: Load product data into fields, disable SKU
    If Add mode: Clear fields, enable SKU
cmdSave_Click -> Validate all fields -> 
    If Add: AddProduct -> Success msg -> Unload
    If Edit: UpdateProduct -> Success msg -> Unload
cmdCancel_Click -> Unload Me
```

### 6.5 frmReport Event Flow
```
Form_Load -> Select Summary option by default
cmdGenerate_Click -> Determine selected report type -> Generate report text -> Display in txtReport
cmdExport_Click -> Show SaveAs dialog -> Write txtReport to file
cmdClose_Click -> Unload Me
```

### 6.6 frmAbout Event Flow
```
Form_Load -> Populate labels with constants
cmdOK_Click -> Unload Me
```

---

## 7. Error Handling Strategy

All procedures follow this pattern:
```vb
Public Sub SomeProcedure()
    On Error GoTo ErrorHandler
    
    ' ... procedure logic ...
    
    Exit Sub
ErrorHandler:
    LogError "ModuleName.SomeProcedure", Err.Number, Err.Description
    MsgBox "An error occurred: " & Err.Description, vbExclamation, APP_NAME
End Sub
```

---

## 8. Global Variables

```vb
' modDatabase.bas
Public g_Connection As ADODB.Connection    ' Global ADO connection
Public g_CurrentUser As clsUser            ' Currently logged-in user
```

---

## 9. VB6 Project References

| Reference                                  | Purpose                    |
|--------------------------------------------|----------------------------|
| Microsoft ActiveX Data Objects 2.8 Library | ADO database access        |
| Microsoft Jet and Replication Objects 2.6   | Jet 4.0 engine             |
| Microsoft Common Dialog Control 6.0        | File save dialogs          |
| Microsoft Windows Common Controls 6.0      | ListView, Toolbar, StatusBar, ImageList |

---

## 10. Color Scheme

| Element             | Color                | VB6 Value      |
|---------------------|----------------------|----------------|
| Normal Row          | White                | vbWhite        |
| Low Stock Row       | Orange               | RGB(255,200,100) |
| Out of Stock Row    | Light Red            | RGB(255,180,180) |
| Status Bar          | Default (3D)         | System default |
| Form Background     | Default (ButtonFace) | System default |
