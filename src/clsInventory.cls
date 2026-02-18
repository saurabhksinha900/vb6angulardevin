VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsInventory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Function GetAllProducts() As Collection
    On Error GoTo ErrorHandler
    
    Dim Col As New Collection
    Dim rs As ADODB.Recordset
    Dim Product As clsProduct
    
    Set rs = modDatabase.GetAllProducts()
    
    If rs Is Nothing Then
        Set GetAllProducts = Col
        Exit Function
    End If
    
    Do While Not rs.EOF
        Set Product = New clsProduct
        Product.LoadFromRecordset rs
        Col.Add Product
        rs.MoveNext
    Loop
    
    rs.Close
    Set rs = Nothing
    Set GetAllProducts = Col
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetAllProducts", Err.Number, Err.Description
    Set GetAllProducts = New Collection
End Function

Public Function GetProductByID(ByVal ProductID As Long) As clsProduct
    On Error GoTo ErrorHandler
    
    Dim rs As ADODB.Recordset
    Dim Product As clsProduct
    
    Set rs = modDatabase.GetProductByID(ProductID)
    
    If rs Is Nothing Then
        Set GetProductByID = Nothing
        Exit Function
    End If
    
    If rs.EOF Then
        Set GetProductByID = Nothing
        rs.Close
        Set rs = Nothing
        Exit Function
    End If
    
    Set Product = New clsProduct
    Product.LoadFromRecordset rs
    
    rs.Close
    Set rs = Nothing
    Set GetProductByID = Product
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetProductByID", Err.Number, Err.Description
    Set GetProductByID = Nothing
End Function

Public Function AddProduct(ByVal Product As clsProduct) As Boolean
    On Error GoTo ErrorHandler
    
    Dim ValidationErrors As String
    ValidationErrors = Product.Validate()
    
    If Len(ValidationErrors) > 0 Then
        MsgBox "Validation Errors:" & vbCrLf & vbCrLf & ValidationErrors, vbExclamation, APP_NAME
        AddProduct = False
        Exit Function
    End If
    
    Dim ExistingRS As ADODB.Recordset
    Set ExistingRS = modDatabase.GetProductBySKU(Product.SKU)
    If Not ExistingRS Is Nothing Then
        If Not ExistingRS.EOF Then
            MsgBox "A product with SKU '" & Product.SKU & "' already exists.", vbExclamation, APP_NAME
            ExistingRS.Close
            Set ExistingRS = Nothing
            AddProduct = False
            Exit Function
        End If
        ExistingRS.Close
        Set ExistingRS = Nothing
    End If
    
    AddProduct = modDatabase.AddProduct(Product.SKU, Product.ProductName, Product.Category, _
                                         Product.Price, Product.Quantity, Product.ReorderLevel)
    Exit Function

ErrorHandler:
    LogError "clsInventory.AddProduct", Err.Number, Err.Description
    AddProduct = False
End Function

Public Function UpdateProduct(ByVal Product As clsProduct) As Boolean
    On Error GoTo ErrorHandler
    
    Dim ValidationErrors As String
    ValidationErrors = Product.Validate()
    
    If Len(ValidationErrors) > 0 Then
        MsgBox "Validation Errors:" & vbCrLf & vbCrLf & ValidationErrors, vbExclamation, APP_NAME
        UpdateProduct = False
        Exit Function
    End If
    
    UpdateProduct = modDatabase.UpdateProduct(Product.ProductID, Product.ProductName, _
                                               Product.Category, Product.Price, _
                                               Product.Quantity, Product.ReorderLevel)
    Exit Function

ErrorHandler:
    LogError "clsInventory.UpdateProduct", Err.Number, Err.Description
    UpdateProduct = False
End Function

Public Function DeleteProduct(ByVal ProductID As Long) As Boolean
    On Error GoTo ErrorHandler
    
    DeleteProduct = modDatabase.DeleteProduct(ProductID)
    Exit Function

ErrorHandler:
    LogError "clsInventory.DeleteProduct", Err.Number, Err.Description
    DeleteProduct = False
End Function

Public Function SearchProducts(ByVal SearchName As String, ByVal FilterCategory As String) As Collection
    On Error GoTo ErrorHandler
    
    Dim Col As New Collection
    Dim rs As ADODB.Recordset
    Dim Product As clsProduct
    
    Set rs = modDatabase.SearchProducts(SearchName, FilterCategory)
    
    If rs Is Nothing Then
        Set SearchProducts = Col
        Exit Function
    End If
    
    Do While Not rs.EOF
        Set Product = New clsProduct
        Product.LoadFromRecordset rs
        Col.Add Product
        rs.MoveNext
    Loop
    
    rs.Close
    Set rs = Nothing
    Set SearchProducts = Col
    Exit Function

ErrorHandler:
    LogError "clsInventory.SearchProducts", Err.Number, Err.Description
    Set SearchProducts = New Collection
End Function

Public Function GetSummaryReport() As String
    On Error GoTo ErrorHandler
    
    Dim Report As String
    Dim Sep As String
    
    Sep = RepeatString("=", 50)
    
    Report = "INVENTORY SUMMARY REPORT" & vbCrLf
    Report = Report & "Generated: " & FormatDateTime_Custom(Now) & vbCrLf
    Report = Report & Sep & vbCrLf & vbCrLf
    
    Report = Report & "Total Products:        " & FormatAsInteger(GetProductCount()) & vbCrLf
    Report = Report & "Total Inventory Value:  " & FormatAsCurrency(GetTotalInventoryValue()) & vbCrLf
    Report = Report & "Average Product Price:  " & FormatAsCurrency(GetAveragePrice()) & vbCrLf
    Report = Report & "Total Quantity in Stock: " & FormatAsInteger(GetTotalQuantity()) & vbCrLf
    Report = Report & "Categories with Products: " & FormatAsInteger(GetCategoryCount()) & vbCrLf
    Report = Report & "Low Stock Items:        " & FormatAsInteger(GetLowStockCount()) & vbCrLf
    Report = Report & vbCrLf & Sep & vbCrLf
    Report = Report & "End of Report" & vbCrLf
    
    GetSummaryReport = Report
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetSummaryReport", Err.Number, Err.Description
    GetSummaryReport = "Error generating report: " & Err.Description
End Function

Public Function GetCategoryReport() As String
    On Error GoTo ErrorHandler
    
    Dim Report As String
    Dim Sep As String
    Dim rs As ADODB.Recordset
    
    Sep = RepeatString("=", 60)
    
    Report = "INVENTORY BY CATEGORY REPORT" & vbCrLf
    Report = Report & "Generated: " & FormatDateTime_Custom(Now) & vbCrLf
    Report = Report & Sep & vbCrLf & vbCrLf
    
    Report = Report & PadString("Category", 20) & PadString("Count", 10) & _
             PadString("Total Value", 18) & PadString("Avg Price", 15) & vbCrLf
    Report = Report & RepeatString("-", 60) & vbCrLf
    
    Set rs = GetProductsByCategory()
    
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Report = Report & PadString(SafeString(rs.Fields("Category").Value), 20)
            Report = Report & PadString(CStr(SafeLong(rs.Fields("ProductCount").Value)), 10)
            Report = Report & PadString(FormatAsCurrency(SafeCurrency(rs.Fields("TotalValue").Value)), 18)
            Report = Report & PadString(FormatAsCurrency(SafeCurrency(rs.Fields("AvgPrice").Value)), 15)
            Report = Report & vbCrLf
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
    End If
    
    Report = Report & vbCrLf & Sep & vbCrLf
    Report = Report & "End of Report" & vbCrLf
    
    GetCategoryReport = Report
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetCategoryReport", Err.Number, Err.Description
    GetCategoryReport = "Error generating report: " & Err.Description
End Function

Public Function GetLowStockReport() As String
    On Error GoTo ErrorHandler
    
    Dim Report As String
    Dim Sep As String
    Dim rs As ADODB.Recordset
    Dim Shortage As Long
    
    Sep = RepeatString("=", 80)
    
    Report = "LOW STOCK ALERT REPORT" & vbCrLf
    Report = Report & "Generated: " & FormatDateTime_Custom(Now) & vbCrLf
    Report = Report & Sep & vbCrLf & vbCrLf
    
    Report = Report & PadString("SKU", 16) & PadString("Name", 22) & _
             PadString("Category", 16) & PadString("Qty", 8) & _
             PadString("Reorder", 10) & PadString("Shortage", 10) & vbCrLf
    Report = Report & RepeatString("-", 80) & vbCrLf
    
    Set rs = modDatabase.GetLowStockProducts()
    
    If Not rs Is Nothing Then
        If rs.EOF Then
            Report = Report & vbCrLf & "No low stock items found." & vbCrLf
        Else
            Do While Not rs.EOF
                Shortage = SafeLong(rs.Fields("ReorderLevel").Value) - SafeLong(rs.Fields("Quantity").Value)
                
                Report = Report & PadString(SafeString(rs.Fields("SKU").Value), 16)
                Report = Report & PadString(TruncateString(SafeString(rs.Fields("ProductName").Value), 20), 22)
                Report = Report & PadString(SafeString(rs.Fields("Category").Value), 16)
                Report = Report & PadString(CStr(SafeLong(rs.Fields("Quantity").Value)), 8)
                Report = Report & PadString(CStr(SafeLong(rs.Fields("ReorderLevel").Value)), 10)
                Report = Report & PadString(CStr(Shortage), 10)
                Report = Report & vbCrLf
                rs.MoveNext
            Loop
        End If
        rs.Close
        Set rs = Nothing
    End If
    
    Report = Report & vbCrLf & Sep & vbCrLf
    Report = Report & "Total Low Stock Items: " & FormatAsInteger(GetLowStockCount()) & vbCrLf
    Report = Report & "End of Report" & vbCrLf
    
    GetLowStockReport = Report
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetLowStockReport", Err.Number, Err.Description
    GetLowStockReport = "Error generating report: " & Err.Description
End Function

Public Function GetValueReport() As String
    On Error GoTo ErrorHandler
    
    Dim Report As String
    Dim Sep As String
    Dim rs As ADODB.Recordset
    Dim GrandTotal As Currency
    
    Sep = RepeatString("=", 75)
    GrandTotal = 0
    
    Report = "INVENTORY VALUE REPORT" & vbCrLf
    Report = Report & "Generated: " & FormatDateTime_Custom(Now) & vbCrLf
    Report = Report & Sep & vbCrLf & vbCrLf
    
    Report = Report & PadString("SKU", 16) & PadString("Name", 22) & _
             PadString("Price", 14) & PadString("Qty", 10) & _
             PadString("Total Value", 15) & vbCrLf
    Report = Report & RepeatString("-", 75) & vbCrLf
    
    Set rs = modDatabase.GetProductsByValue()
    
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Dim TotalVal As Currency
            TotalVal = SafeCurrency(rs.Fields("TotalValue").Value)
            GrandTotal = GrandTotal + TotalVal
            
            Report = Report & PadString(SafeString(rs.Fields("SKU").Value), 16)
            Report = Report & PadString(TruncateString(SafeString(rs.Fields("ProductName").Value), 20), 22)
            Report = Report & PadString(FormatAsCurrency(SafeCurrency(rs.Fields("Price").Value)), 14)
            Report = Report & PadString(FormatAsInteger(SafeLong(rs.Fields("Quantity").Value)), 10)
            Report = Report & PadString(FormatAsCurrency(TotalVal), 15)
            Report = Report & vbCrLf
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
    End If
    
    Report = Report & RepeatString("-", 75) & vbCrLf
    Report = Report & PadString("", 52) & "Grand Total: " & FormatAsCurrency(GrandTotal) & vbCrLf
    Report = Report & vbCrLf & Sep & vbCrLf
    Report = Report & "End of Report" & vbCrLf
    
    GetValueReport = Report
    Exit Function

ErrorHandler:
    LogError "clsInventory.GetValueReport", Err.Number, Err.Description
    GetValueReport = "Error generating report: " & Err.Description
End Function

Public Function GetProductCount() As Long
    GetProductCount = modDatabase.GetProductCount()
End Function

Public Function GetTotalValue() As Currency
    GetTotalValue = modDatabase.GetTotalInventoryValue()
End Function

Public Function GetLowStockCount() As Long
    GetLowStockCount = modDatabase.GetLowStockCount()
End Function
