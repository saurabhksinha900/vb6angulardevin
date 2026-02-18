VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsProduct"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_ProductID As Long
Private m_SKU As String
Private m_ProductName As String
Private m_Category As String
Private m_Price As Currency
Private m_Quantity As Long
Private m_ReorderLevel As Long

Public Property Get ProductID() As Long
    ProductID = m_ProductID
End Property

Public Property Let ProductID(ByVal Value As Long)
    m_ProductID = Value
End Property

Public Property Get SKU() As String
    SKU = m_SKU
End Property

Public Property Let SKU(ByVal Value As String)
    m_SKU = Value
End Property

Public Property Get ProductName() As String
    ProductName = m_ProductName
End Property

Public Property Let ProductName(ByVal Value As String)
    m_ProductName = Value
End Property

Public Property Get Category() As String
    Category = m_Category
End Property

Public Property Let Category(ByVal Value As String)
    m_Category = Value
End Property

Public Property Get Price() As Currency
    Price = m_Price
End Property

Public Property Let Price(ByVal Value As Currency)
    m_Price = Value
End Property

Public Property Get Quantity() As Long
    Quantity = m_Quantity
End Property

Public Property Let Quantity(ByVal Value As Long)
    m_Quantity = Value
End Property

Public Property Get ReorderLevel() As Long
    ReorderLevel = m_ReorderLevel
End Property

Public Property Let ReorderLevel(ByVal Value As Long)
    m_ReorderLevel = Value
End Property

Public Property Get TotalValue() As Currency
    TotalValue = m_Price * m_Quantity
End Property

Public Property Get Status() As String
    Status = GetProductStatus(m_Quantity, m_ReorderLevel)
End Property

Public Property Get IsLowStock() As Boolean
    IsLowStock = (m_Quantity <= m_ReorderLevel)
End Property

Public Property Get IsOutOfStock() As Boolean
    IsOutOfStock = (m_Quantity = 0)
End Property

Public Function Validate() As String
    Dim Errors As String
    Errors = ""
    
    If Not IsRequiredField(m_SKU) Then
        Errors = Errors & "SKU is required." & vbCrLf
    ElseIf Not IsValidSKU(m_SKU) Then
        Errors = Errors & "SKU must be in format XXX-XXXX-XXXX (alphanumeric)." & vbCrLf
    End If
    
    If Not IsRequiredField(m_ProductName) Then
        Errors = Errors & "Product Name is required." & vbCrLf
    ElseIf Len(m_ProductName) > PRODUCT_NAME_MAX Then
        Errors = Errors & "Product Name must be 100 characters or less." & vbCrLf
    End If
    
    If Not IsRequiredField(m_Category) Then
        Errors = Errors & "Category is required." & vbCrLf
    End If
    
    If m_Price < PRICE_MIN Or m_Price > PRICE_MAX Then
        Errors = Errors & "Price must be between " & FormatAsCurrency(PRICE_MIN) & " and " & FormatAsCurrency(PRICE_MAX) & "." & vbCrLf
    End If
    
    If m_Quantity < QTY_MIN Or m_Quantity > QTY_MAX Then
        Errors = Errors & "Quantity must be between " & QTY_MIN & " and " & FormatAsInteger(QTY_MAX) & "." & vbCrLf
    End If
    
    If m_ReorderLevel < QTY_MIN Or m_ReorderLevel > QTY_MAX Then
        Errors = Errors & "Reorder Level must be between " & QTY_MIN & " and " & FormatAsInteger(QTY_MAX) & "." & vbCrLf
    End If
    
    Validate = Errors
End Function

Public Sub LoadFromRecordset(ByVal rs As ADODB.Recordset)
    m_ProductID = SafeLong(rs.Fields("ProductID").Value)
    m_SKU = SafeString(rs.Fields("SKU").Value)
    m_ProductName = SafeString(rs.Fields("ProductName").Value)
    m_Category = SafeString(rs.Fields("Category").Value)
    m_Price = SafeCurrency(rs.Fields("Price").Value)
    m_Quantity = SafeLong(rs.Fields("Quantity").Value)
    m_ReorderLevel = SafeLong(rs.Fields("ReorderLevel").Value)
End Sub

Public Sub Clear()
    m_ProductID = 0
    m_SKU = ""
    m_ProductName = ""
    m_Category = ""
    m_Price = 0
    m_Quantity = 0
    m_ReorderLevel = 0
End Sub

Private Sub Class_Initialize()
    Clear
End Sub
