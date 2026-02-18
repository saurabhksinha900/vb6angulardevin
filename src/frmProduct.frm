VERSION 5.00
Begin VB.Form frmProduct 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Product"
   ClientHeight    =   5400
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   5400
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5400
   ScaleWidth      =   5400
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   2880
      TabIndex        =   8
      Top             =   4680
      Width           =   1575
   End
   Begin VB.CommandButton cmdSave 
      Caption         =   "&Save"
      Default         =   -1  'True
      Height          =   495
      Left            =   960
      TabIndex        =   7
      Top             =   4680
      Width           =   1575
   End
   Begin VB.TextBox txtReorderLevel 
      Alignment       =   1  'Right Justify
      Height          =   315
      Left            =   2160
      MaxLength       =   6
      TabIndex        =   6
      Top             =   4080
      Width           =   2295
   End
   Begin VB.TextBox txtQuantity 
      Alignment       =   1  'Right Justify
      Height          =   315
      Left            =   2160
      MaxLength       =   6
      TabIndex        =   5
      Top             =   3480
      Width           =   2295
   End
   Begin VB.TextBox txtPrice 
      Alignment       =   1  'Right Justify
      Height          =   315
      Left            =   2160
      MaxLength       =   12
      TabIndex        =   4
      Top             =   2880
      Width           =   2295
   End
   Begin VB.ComboBox cboCategory 
      Height          =   315
      Left            =   2160
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   2280
      Width           =   2295
   End
   Begin VB.TextBox txtProductName 
      Height          =   315
      Left            =   2160
      MaxLength       =   100
      TabIndex        =   2
      Top             =   1680
      Width           =   2295
   End
   Begin VB.TextBox txtSKU 
      Height          =   315
      Left            =   2160
      MaxLength       =   14
      TabIndex        =   1
      Top             =   1080
      Width           =   2295
   End
   Begin VB.Label lblReorderHint 
      Caption         =   "(0 - 999,999)"
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   2160
      TabIndex        =   16
      Top             =   4400
      Width           =   2295
   End
   Begin VB.Label lblQtyHint 
      Caption         =   "(0 - 999,999)"
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   2160
      TabIndex        =   15
      Top             =   3800
      Width           =   2295
   End
   Begin VB.Label lblPriceHint 
      Caption         =   "($0.01 - $999,999.99)"
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   2160
      TabIndex        =   14
      Top             =   3200
      Width           =   2295
   End
   Begin VB.Label lblSKUHint 
      Caption         =   "(Format: XXX-XXXX-XXXX)"
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   2160
      TabIndex        =   13
      Top             =   1400
      Width           =   2295
   End
   Begin VB.Label lblReorderLevel 
      Caption         =   "Reorder Level:"
      Height          =   255
      Left            =   480
      TabIndex        =   12
      Top             =   4140
      Width           =   1575
   End
   Begin VB.Label lblQuantity 
      Caption         =   "Quantity:"
      Height          =   255
      Left            =   480
      TabIndex        =   11
      Top             =   3540
      Width           =   1575
   End
   Begin VB.Label lblPrice 
      Caption         =   "Price ($):"
      Height          =   255
      Left            =   480
      TabIndex        =   10
      Top             =   2940
      Width           =   1575
   End
   Begin VB.Label lblCategory 
      Caption         =   "Category:"
      Height          =   255
      Left            =   480
      TabIndex        =   9
      Top             =   2340
      Width           =   1575
   End
   Begin VB.Label lblProductName 
      Caption         =   "Product Name:"
      Height          =   255
      Left            =   480
      TabIndex        =   0
      Top             =   1740
      Width           =   1575
   End
   Begin VB.Label lblSKU 
      Caption         =   "SKU:"
      Height          =   255
      Left            =   480
      TabIndex        =   17
      Top             =   1140
      Width           =   1575
   End
   Begin VB.Label lblFormTitle 
      Alignment       =   2  'Center
      Caption         =   "Add Product"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   18
      Top             =   360
      Width           =   4935
   End
End
Attribute VB_Name = "frmProduct"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_FormMode As Integer
Private m_ProductID As Long
Private m_Inventory As clsInventory

Public Property Let FormMode(ByVal Value As Integer)
    m_FormMode = Value
End Property

Public Property Get FormMode() As Integer
    FormMode = m_FormMode
End Property

Public Property Let ProductID(ByVal Value As Long)
    m_ProductID = Value
End Property

Public Property Get ProductID() As Long
    ProductID = m_ProductID
End Property

Private Sub Form_Load()
    On Error GoTo ErrorHandler
    
    Set m_Inventory = New clsInventory
    
    PopulateCategories
    
    If m_FormMode = MODE_EDIT Then
        Me.Caption = "Edit Product"
        lblFormTitle.Caption = "Edit Product"
        LoadProductData
        txtSKU.Enabled = False
        txtSKU.BackColor = &HC0C0C0
    Else
        Me.Caption = "Add Product"
        lblFormTitle.Caption = "Add Product"
        ClearFields
        txtSKU.Enabled = True
        txtSKU.SetFocus
    End If
    
    Exit Sub

ErrorHandler:
    LogError "frmProduct.Form_Load", Err.Number, Err.Description
    MsgBox "Error loading product form: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub PopulateCategories()
    cboCategory.Clear
    cboCategory.AddItem CAT_ELECTRONICS
    cboCategory.AddItem CAT_CLOTHING
    cboCategory.AddItem CAT_FOOD
    cboCategory.AddItem CAT_FURNITURE
    cboCategory.AddItem CAT_OFFICE_SUPPLIES
    cboCategory.AddItem CAT_OTHER
End Sub

Private Sub LoadProductData()
    On Error GoTo ErrorHandler
    
    Dim Product As clsProduct
    Set Product = m_Inventory.GetProductByID(m_ProductID)
    
    If Product Is Nothing Then
        MsgBox "Product not found.", vbExclamation, APP_NAME
        Unload Me
        Exit Sub
    End If
    
    txtSKU.Text = Product.SKU
    txtProductName.Text = Product.ProductName
    
    Dim i As Integer
    For i = 0 To cboCategory.ListCount - 1
        If cboCategory.List(i) = Product.Category Then
            cboCategory.ListIndex = i
            Exit For
        End If
    Next i
    
    txtPrice.Text = Format$(Product.Price, "0.00")
    txtQuantity.Text = CStr(Product.Quantity)
    txtReorderLevel.Text = CStr(Product.ReorderLevel)
    
    Exit Sub

ErrorHandler:
    LogError "frmProduct.LoadProductData", Err.Number, Err.Description
    MsgBox "Error loading product data: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub ClearFields()
    txtSKU.Text = ""
    txtProductName.Text = ""
    cboCategory.ListIndex = -1
    txtPrice.Text = ""
    txtQuantity.Text = ""
    txtReorderLevel.Text = ""
End Sub

Private Sub cmdSave_Click()
    On Error GoTo ErrorHandler
    
    If Not ValidateForm() Then Exit Sub
    
    Dim Product As New clsProduct
    
    Product.SKU = Trim$(txtSKU.Text)
    Product.ProductName = Trim$(txtProductName.Text)
    Product.Category = cboCategory.Text
    Product.Price = CCur(txtPrice.Text)
    Product.Quantity = CLng(txtQuantity.Text)
    Product.ReorderLevel = CLng(txtReorderLevel.Text)
    
    Dim Success As Boolean
    
    If m_FormMode = MODE_ADD Then
        Success = m_Inventory.AddProduct(Product)
        If Success Then
            MsgBox "Product added successfully.", vbInformation, APP_NAME
            Unload Me
        End If
    Else
        Product.ProductID = m_ProductID
        Success = m_Inventory.UpdateProduct(Product)
        If Success Then
            MsgBox "Product updated successfully.", vbInformation, APP_NAME
            Unload Me
        End If
    End If
    
    Exit Sub

ErrorHandler:
    LogError "frmProduct.cmdSave_Click", Err.Number, Err.Description
    MsgBox "Error saving product: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Function ValidateForm() As Boolean
    If Not IsRequiredField(txtSKU.Text) Then
        MsgBox "SKU is required.", vbExclamation, APP_NAME
        txtSKU.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If Not IsValidSKU(Trim$(txtSKU.Text)) Then
        MsgBox "SKU must be in format XXX-XXXX-XXXX (alphanumeric characters).", vbExclamation, APP_NAME
        txtSKU.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If Not IsRequiredField(txtProductName.Text) Then
        MsgBox "Product Name is required.", vbExclamation, APP_NAME
        txtProductName.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If cboCategory.ListIndex = -1 Then
        MsgBox "Please select a category.", vbExclamation, APP_NAME
        cboCategory.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If Not IsValidPrice(txtPrice.Text) Then
        MsgBox "Price must be a number between $0.01 and $999,999.99.", vbExclamation, APP_NAME
        txtPrice.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If Not IsValidQuantity(txtQuantity.Text) Then
        MsgBox "Quantity must be a whole number between 0 and 999,999.", vbExclamation, APP_NAME
        txtQuantity.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    If Not IsValidQuantity(txtReorderLevel.Text) Then
        MsgBox "Reorder Level must be a whole number between 0 and 999,999.", vbExclamation, APP_NAME
        txtReorderLevel.SetFocus
        ValidateForm = False
        Exit Function
    End If
    
    ValidateForm = True
End Function

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set m_Inventory = Nothing
End Sub
