VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmMain 
   Caption         =   "VB6 Inventory Management System"
   ClientHeight    =   8400
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   12600
   LinkTopic       =   "Form1"
   ScaleHeight     =   8400
   ScaleWidth      =   12600
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CommandButton cmdClear 
      Caption         =   "C&lear"
      Height          =   375
      Left            =   10440
      TabIndex        =   10
      Top             =   960
      Width           =   975
   End
   Begin VB.CommandButton cmdSearch 
      Caption         =   "&Search"
      Height          =   375
      Left            =   9360
      TabIndex        =   9
      Top             =   960
      Width           =   975
   End
   Begin VB.ComboBox cboCategory 
      Height          =   315
      Left            =   6600
      Style           =   2  'Dropdown List
      TabIndex        =   8
      Top             =   1000
      Width           =   2535
   End
   Begin VB.TextBox txtSearch 
      Height          =   315
      Left            =   1200
      MaxLength       =   100
      TabIndex        =   7
      Top             =   1000
      Width           =   3135
   End
   Begin VB.CommandButton cmdRefresh 
      Caption         =   "Re&fresh"
      Height          =   495
      Left            =   5760
      TabIndex        =   6
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton cmdReport 
      Caption         =   "&Report"
      Height          =   495
      Left            =   4320
      TabIndex        =   5
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton cmdDelete 
      Caption         =   "&Delete"
      Height          =   495
      Left            =   2880
      TabIndex        =   4
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton cmdEdit 
      Caption         =   "&Edit"
      Height          =   495
      Left            =   1440
      TabIndex        =   3
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton cmdAdd 
      Caption         =   "&Add"
      Height          =   495
      Left            =   120
      TabIndex        =   2
      Top             =   360
      Width           =   1215
   End
   Begin MSComctlLib.ListView lvwProducts 
      Height          =   6375
      Left            =   120
      TabIndex        =   1
      Top             =   1500
      Width           =   12375
      _ExtentX        =   21828
      _ExtentY        =   11245
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin MSComctlLib.StatusBar staMain 
      Align           =   2  'Align Bottom
      Height          =   375
      Left            =   0
      TabIndex        =   0
      Top             =   8040
      Width           =   12600
      _ExtentX        =   22225
      _ExtentY        =   661
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   4
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   3000
            Text            =   "User: "
            TextSave        =   "User: "
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   2000
            Text            =   "Products: 0"
            TextSave        =   "Products: 0"
         EndProperty
         BeginProperty Panel3 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   2000
            Text            =   "Low Stock: 0"
            TextSave        =   "Low Stock: 0"
         EndProperty
         BeginProperty Panel4 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   3000
            Text            =   "Value: $0.00"
            TextSave        =   "Value: $0.00"
         EndProperty
      EndProperty
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu mnuProducts 
      Caption         =   "&Products"
      Begin VB.Menu mnuProductAdd 
         Caption         =   "&Add Product"
      End
      Begin VB.Menu mnuProductEdit 
         Caption         =   "&Edit Product"
      End
      Begin VB.Menu mnuProductDelete 
         Caption         =   "&Delete Product"
      End
   End
   Begin VB.Menu mnuReports 
      Caption         =   "&Reports"
      Begin VB.Menu mnuReportGenerate 
         Caption         =   "&Generate Report"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "&About"
      End
   End
   Begin VB.Label lblCategory 
      Caption         =   "Category:"
      Height          =   255
      Left            =   5640
      TabIndex        =   12
      Top             =   1020
      Width           =   855
   End
   Begin VB.Label lblSearch 
      Caption         =   "Search:"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   1020
      Width           =   855
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_SelectedProductID As Long
Private m_Inventory As clsInventory

Private Sub Form_Load()
    On Error GoTo ErrorHandler
    
    Set m_Inventory = New clsInventory
    m_SelectedProductID = 0
    
    SetupListView
    SetupCategoryFilter
    ApplyRBAC
    LoadProducts
    UpdateStatusBar
    
    Me.Caption = APP_NAME & " - Logged in as: " & g_CurrentUser.FullName & " (" & g_CurrentUser.Role & ")"
    
    Exit Sub

ErrorHandler:
    LogError "frmMain.Form_Load", Err.Number, Err.Description
    MsgBox "Error loading main form: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub SetupListView()
    With lvwProducts
        .ColumnHeaders.Clear
        .ColumnHeaders.Add , "colID", "ID", 600
        .ColumnHeaders.Add , "colSKU", "SKU", 1800
        .ColumnHeaders.Add , "colName", "Name", 2400
        .ColumnHeaders.Add , "colCategory", "Category", 1600
        .ColumnHeaders.Add , "colPrice", "Price", 1200, lvwColumnRight
        .ColumnHeaders.Add , "colQty", "Qty", 800, lvwColumnRight
        .ColumnHeaders.Add , "colReorder", "Reorder Lvl", 1200, lvwColumnRight
        .ColumnHeaders.Add , "colTotalValue", "Total Value", 1500, lvwColumnRight
        .ColumnHeaders.Add , "colStatus", "Status", 1200
    End With
End Sub

Private Sub SetupCategoryFilter()
    cboCategory.Clear
    cboCategory.AddItem CAT_ALL
    cboCategory.AddItem CAT_ELECTRONICS
    cboCategory.AddItem CAT_CLOTHING
    cboCategory.AddItem CAT_FOOD
    cboCategory.AddItem CAT_FURNITURE
    cboCategory.AddItem CAT_OFFICE_SUPPLIES
    cboCategory.AddItem CAT_OTHER
    cboCategory.ListIndex = 0
End Sub

Private Sub ApplyRBAC()
    If g_CurrentUser Is Nothing Then Exit Sub
    
    cmdAdd.Enabled = g_CurrentUser.CanAddProduct
    cmdEdit.Enabled = g_CurrentUser.CanEditProduct
    cmdDelete.Enabled = g_CurrentUser.CanDeleteProduct
    
    mnuProductAdd.Enabled = g_CurrentUser.CanAddProduct
    mnuProductEdit.Enabled = g_CurrentUser.CanEditProduct
    mnuProductDelete.Enabled = g_CurrentUser.CanDeleteProduct
End Sub

Private Sub LoadProducts()
    On Error GoTo ErrorHandler
    
    Dim Products As Collection
    Dim Product As clsProduct
    Dim li As MSComctlLib.ListItem
    
    lvwProducts.ListItems.Clear
    m_SelectedProductID = 0
    
    Set Products = m_Inventory.GetAllProducts()
    
    Dim i As Long
    For i = 1 To Products.Count
        Set Product = Products(i)
        Set li = lvwProducts.ListItems.Add(, "K" & Product.ProductID, CStr(Product.ProductID))
        li.SubItems(1) = Product.SKU
        li.SubItems(2) = Product.ProductName
        li.SubItems(3) = Product.Category
        li.SubItems(4) = FormatAsCurrency(Product.Price)
        li.SubItems(5) = FormatAsInteger(Product.Quantity)
        li.SubItems(6) = FormatAsInteger(Product.ReorderLevel)
        li.SubItems(7) = FormatAsCurrency(Product.TotalValue)
        li.SubItems(8) = Product.Status
        
        If Product.IsOutOfStock Then
            li.ForeColor = vbRed
        ElseIf Product.IsLowStock Then
            li.ForeColor = RGB(200, 120, 0)
        End If
    Next i
    
    UpdateStatusBar
    Exit Sub

ErrorHandler:
    LogError "frmMain.LoadProducts", Err.Number, Err.Description
    MsgBox "Error loading products: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub LoadFilteredProducts(ByVal SearchName As String, ByVal FilterCategory As String)
    On Error GoTo ErrorHandler
    
    Dim Products As Collection
    Dim Product As clsProduct
    Dim li As MSComctlLib.ListItem
    
    lvwProducts.ListItems.Clear
    m_SelectedProductID = 0
    
    Set Products = m_Inventory.SearchProducts(SearchName, FilterCategory)
    
    Dim i As Long
    For i = 1 To Products.Count
        Set Product = Products(i)
        Set li = lvwProducts.ListItems.Add(, "K" & Product.ProductID, CStr(Product.ProductID))
        li.SubItems(1) = Product.SKU
        li.SubItems(2) = Product.ProductName
        li.SubItems(3) = Product.Category
        li.SubItems(4) = FormatAsCurrency(Product.Price)
        li.SubItems(5) = FormatAsInteger(Product.Quantity)
        li.SubItems(6) = FormatAsInteger(Product.ReorderLevel)
        li.SubItems(7) = FormatAsCurrency(Product.TotalValue)
        li.SubItems(8) = Product.Status
        
        If Product.IsOutOfStock Then
            li.ForeColor = vbRed
        ElseIf Product.IsLowStock Then
            li.ForeColor = RGB(200, 120, 0)
        End If
    Next i
    
    Exit Sub

ErrorHandler:
    LogError "frmMain.LoadFilteredProducts", Err.Number, Err.Description
    MsgBox "Error searching products: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub UpdateStatusBar()
    On Error Resume Next
    
    staMain.Panels(1).Text = "User: " & g_CurrentUser.FullName & " (" & g_CurrentUser.Role & ")"
    staMain.Panels(2).Text = "Products: " & m_Inventory.GetProductCount()
    staMain.Panels(3).Text = "Low Stock: " & m_Inventory.GetLowStockCount()
    staMain.Panels(4).Text = "Value: " & FormatAsCurrency(m_Inventory.GetTotalValue())
End Sub

Private Sub lvwProducts_ItemClick(ByVal Item As MSComctlLib.ListItem)
    m_SelectedProductID = CLng(Item.Text)
End Sub

Private Sub cmdAdd_Click()
    DoAddProduct
End Sub

Private Sub mnuProductAdd_Click()
    DoAddProduct
End Sub

Private Sub DoAddProduct()
    On Error GoTo ErrorHandler
    
    frmProduct.FormMode = MODE_ADD
    frmProduct.ProductID = 0
    frmProduct.Show vbModal
    
    LoadProducts
    Exit Sub

ErrorHandler:
    LogError "frmMain.DoAddProduct", Err.Number, Err.Description
End Sub

Private Sub cmdEdit_Click()
    DoEditProduct
End Sub

Private Sub mnuProductEdit_Click()
    DoEditProduct
End Sub

Private Sub DoEditProduct()
    On Error GoTo ErrorHandler
    
    If m_SelectedProductID = 0 Then
        MsgBox "Please select a product to edit.", vbInformation, APP_NAME
        Exit Sub
    End If
    
    frmProduct.FormMode = MODE_EDIT
    frmProduct.ProductID = m_SelectedProductID
    frmProduct.Show vbModal
    
    LoadProducts
    Exit Sub

ErrorHandler:
    LogError "frmMain.DoEditProduct", Err.Number, Err.Description
End Sub

Private Sub cmdDelete_Click()
    DoDeleteProduct
End Sub

Private Sub mnuProductDelete_Click()
    DoDeleteProduct
End Sub

Private Sub DoDeleteProduct()
    On Error GoTo ErrorHandler
    
    If m_SelectedProductID = 0 Then
        MsgBox "Please select a product to delete.", vbInformation, APP_NAME
        Exit Sub
    End If
    
    Dim Result As VbMsgBoxResult
    Result = MsgBox("Are you sure you want to delete this product?", vbQuestion + vbYesNo, APP_NAME)
    
    If Result = vbYes Then
        If m_Inventory.DeleteProduct(m_SelectedProductID) Then
            MsgBox "Product deleted successfully.", vbInformation, APP_NAME
            m_SelectedProductID = 0
            LoadProducts
        Else
            MsgBox "Failed to delete product.", vbExclamation, APP_NAME
        End If
    End If
    
    Exit Sub

ErrorHandler:
    LogError "frmMain.DoDeleteProduct", Err.Number, Err.Description
    MsgBox "Error deleting product: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub cmdReport_Click()
    DoGenerateReport
End Sub

Private Sub mnuReportGenerate_Click()
    DoGenerateReport
End Sub

Private Sub DoGenerateReport()
    On Error GoTo ErrorHandler
    
    frmReport.Show vbModal
    Exit Sub

ErrorHandler:
    LogError "frmMain.DoGenerateReport", Err.Number, Err.Description
End Sub

Private Sub cmdRefresh_Click()
    txtSearch.Text = ""
    cboCategory.ListIndex = 0
    LoadProducts
End Sub

Private Sub cmdSearch_Click()
    Dim SearchName As String
    Dim FilterCategory As String
    
    SearchName = Trim$(txtSearch.Text)
    FilterCategory = cboCategory.Text
    
    LoadFilteredProducts SearchName, FilterCategory
End Sub

Private Sub cmdClear_Click()
    txtSearch.Text = ""
    cboCategory.ListIndex = 0
    LoadProducts
End Sub

Private Sub mnuFileExit_Click()
    Unload Me
End Sub

Private Sub mnuHelpAbout_Click()
    frmAbout.Show vbModal
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    
    If Me.WindowState = vbMinimized Then Exit Sub
    
    Dim FormWidth As Long
    Dim FormHeight As Long
    
    FormWidth = Me.ScaleWidth
    FormHeight = Me.ScaleHeight
    
    If FormWidth < 5000 Or FormHeight < 3000 Then Exit Sub
    
    lvwProducts.Width = FormWidth - 240
    lvwProducts.Height = FormHeight - lvwProducts.Top - staMain.Height - 120
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set m_Inventory = Nothing
    CloseConnection
    End
End Sub
