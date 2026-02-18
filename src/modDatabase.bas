Attribute VB_Name = "modDatabase"
Option Explicit

Public g_Connection As ADODB.Connection
Public g_CurrentUser As clsUser

Public Sub InitializeDatabase()
    On Error GoTo ErrorHandler
    
    OpenConnection
    CreateTables
    SeedUsers
    SeedProducts
    
    LogMessage "Database initialized successfully."
    Exit Sub

ErrorHandler:
    LogError "modDatabase.InitializeDatabase", Err.Number, Err.Description
    MsgBox "Failed to initialize database: " & Err.Description, vbCritical, APP_NAME
End Sub

Public Sub OpenConnection()
    On Error GoTo ErrorHandler
    
    Set g_Connection = New ADODB.Connection
    g_Connection.Provider = DB_PROVIDER
    g_Connection.ConnectionString = "Data Source=:memory:;"
    
    g_Connection.Open
    
    LogMessage "Database connection opened."
    Exit Sub

ErrorHandler:
    LogError "modDatabase.OpenConnection", Err.Number, Err.Description
    MsgBox "Failed to open database connection: " & Err.Description, vbCritical, APP_NAME
End Sub

Public Sub CloseConnection()
    On Error Resume Next
    
    If Not g_Connection Is Nothing Then
        If g_Connection.State = adStateOpen Then
            g_Connection.Close
        End If
        Set g_Connection = Nothing
    End If
    
    Set g_CurrentUser = Nothing
    
    LogMessage "Database connection closed."
End Sub

Public Function AuthenticateUser(ByVal Username As String, ByVal PasswordHash As String) As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT UserID, Username, PasswordHash, Role, FullName " & _
          "FROM Users WHERE Username = '" & EscapeSQL(Username) & "' " & _
          "AND PasswordHash = '" & EscapeSQL(PasswordHash) & "'"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set AuthenticateUser = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.AuthenticateUser", Err.Number, Err.Description
    Set AuthenticateUser = Nothing
End Function

Public Function GetAllProducts() As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Category, Price, Quantity, ReorderLevel " & _
          "FROM Products ORDER BY ProductID"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetAllProducts = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetAllProducts", Err.Number, Err.Description
    Set GetAllProducts = Nothing
End Function

Public Function GetProductByID(ByVal ProductID As Long) As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Category, Price, Quantity, ReorderLevel " & _
          "FROM Products WHERE ProductID = " & ProductID
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetProductByID = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetProductByID", Err.Number, Err.Description
    Set GetProductByID = Nothing
End Function

Public Function GetProductBySKU(ByVal SKU As String) As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Category, Price, Quantity, ReorderLevel " & _
          "FROM Products WHERE SKU = '" & EscapeSQL(SKU) & "'"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetProductBySKU = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetProductBySKU", Err.Number, Err.Description
    Set GetProductBySKU = Nothing
End Function

Public Function AddProduct(ByVal SKU As String, ByVal ProductName As String, _
    ByVal Category As String, ByVal Price As Currency, _
    ByVal Quantity As Long, ByVal ReorderLevel As Long) As Boolean
    
    On Error GoTo ErrorHandler
    
    Dim SQL As String
    
    SQL = "INSERT INTO Products (SKU, ProductName, Category, Price, Quantity, ReorderLevel) " & _
          "VALUES ('" & EscapeSQL(SKU) & "', '" & EscapeSQL(ProductName) & "', " & _
          "'" & EscapeSQL(Category) & "', " & Price & ", " & Quantity & ", " & ReorderLevel & ")"
    
    g_Connection.Execute SQL
    
    LogMessage "Product added: " & SKU & " - " & ProductName
    AddProduct = True
    Exit Function

ErrorHandler:
    LogError "modDatabase.AddProduct", Err.Number, Err.Description
    AddProduct = False
End Function

Public Function UpdateProduct(ByVal ProductID As Long, ByVal ProductName As String, _
    ByVal Category As String, ByVal Price As Currency, _
    ByVal Quantity As Long, ByVal ReorderLevel As Long) As Boolean
    
    On Error GoTo ErrorHandler
    
    Dim SQL As String
    
    SQL = "UPDATE Products SET ProductName = '" & EscapeSQL(ProductName) & "', " & _
          "Category = '" & EscapeSQL(Category) & "', " & _
          "Price = " & Price & ", " & _
          "Quantity = " & Quantity & ", " & _
          "ReorderLevel = " & ReorderLevel & " " & _
          "WHERE ProductID = " & ProductID
    
    g_Connection.Execute SQL
    
    LogMessage "Product updated: ID=" & ProductID
    UpdateProduct = True
    Exit Function

ErrorHandler:
    LogError "modDatabase.UpdateProduct", Err.Number, Err.Description
    UpdateProduct = False
End Function

Public Function DeleteProduct(ByVal ProductID As Long) As Boolean
    On Error GoTo ErrorHandler
    
    Dim SQL As String
    
    SQL = "DELETE FROM Products WHERE ProductID = " & ProductID
    
    g_Connection.Execute SQL
    
    LogMessage "Product deleted: ID=" & ProductID
    DeleteProduct = True
    Exit Function

ErrorHandler:
    LogError "modDatabase.DeleteProduct", Err.Number, Err.Description
    DeleteProduct = False
End Function

Public Function SearchProducts(ByVal SearchName As String, ByVal FilterCategory As String) As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    Dim WhereClause As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Category, Price, Quantity, ReorderLevel FROM Products"
    
    WhereClause = ""
    
    If Len(Trim$(SearchName)) > 0 Then
        WhereClause = " WHERE ProductName LIKE '%" & EscapeSQL(SearchName) & "%'"
    End If
    
    If Len(Trim$(FilterCategory)) > 0 And FilterCategory <> CAT_ALL Then
        If Len(WhereClause) > 0 Then
            WhereClause = WhereClause & " AND Category = '" & EscapeSQL(FilterCategory) & "'"
        Else
            WhereClause = " WHERE Category = '" & EscapeSQL(FilterCategory) & "'"
        End If
    End If
    
    SQL = SQL & WhereClause & " ORDER BY ProductID"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set SearchProducts = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.SearchProducts", Err.Number, Err.Description
    Set SearchProducts = Nothing
End Function

Public Function GetProductCount() As Long
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT COUNT(*) AS Cnt FROM Products", g_Connection, adOpenStatic, adLockReadOnly
    
    GetProductCount = SafeLong(rs.Fields("Cnt").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetProductCount", Err.Number, Err.Description
    GetProductCount = 0
End Function

Public Function GetTotalInventoryValue() As Currency
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT SUM(Price * Quantity) AS TotalVal FROM Products", g_Connection, adOpenStatic, adLockReadOnly
    
    GetTotalInventoryValue = SafeCurrency(rs.Fields("TotalVal").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetTotalInventoryValue", Err.Number, Err.Description
    GetTotalInventoryValue = 0
End Function

Public Function GetAveragePrice() As Currency
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT AVG(Price) AS AvgPrice FROM Products", g_Connection, adOpenStatic, adLockReadOnly
    
    GetAveragePrice = SafeCurrency(rs.Fields("AvgPrice").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetAveragePrice", Err.Number, Err.Description
    GetAveragePrice = 0
End Function

Public Function GetTotalQuantity() As Long
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT SUM(Quantity) AS TotalQty FROM Products", g_Connection, adOpenStatic, adLockReadOnly
    
    GetTotalQuantity = SafeLong(rs.Fields("TotalQty").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetTotalQuantity", Err.Number, Err.Description
    GetTotalQuantity = 0
End Function

Public Function GetCategoryCount() As Long
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT COUNT(DISTINCT Category) AS CatCnt FROM Products", g_Connection, adOpenStatic, adLockReadOnly
    
    GetCategoryCount = SafeLong(rs.Fields("CatCnt").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetCategoryCount", Err.Number, Err.Description
    GetCategoryCount = 0
End Function

Public Function GetProductsByCategory() As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT Category, COUNT(*) AS ProductCount, SUM(Price * Quantity) AS TotalValue, " & _
          "AVG(Price) AS AvgPrice FROM Products GROUP BY Category ORDER BY Category"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetProductsByCategory = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetProductsByCategory", Err.Number, Err.Description
    Set GetProductsByCategory = Nothing
End Function

Public Function GetLowStockProducts() As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Category, Price, Quantity, ReorderLevel " & _
          "FROM Products WHERE Quantity <= ReorderLevel " & _
          "ORDER BY (ReorderLevel - Quantity) DESC"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetLowStockProducts = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetLowStockProducts", Err.Number, Err.Description
    Set GetLowStockProducts = Nothing
End Function

Public Function GetProductsByValue() As ADODB.Recordset
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    Dim SQL As String
    
    SQL = "SELECT ProductID, SKU, ProductName, Price, Quantity, (Price * Quantity) AS TotalValue " & _
          "FROM Products ORDER BY (Price * Quantity) DESC"
    
    rs.Open SQL, g_Connection, adOpenStatic, adLockReadOnly
    
    Set GetProductsByValue = rs
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetProductsByValue", Err.Number, Err.Description
    Set GetProductsByValue = Nothing
End Function

Public Function GetLowStockCount() As Long
    On Error GoTo ErrorHandler
    
    Dim rs As New ADODB.Recordset
    rs.Open "SELECT COUNT(*) AS Cnt FROM Products WHERE Quantity <= ReorderLevel", g_Connection, adOpenStatic, adLockReadOnly
    
    GetLowStockCount = SafeLong(rs.Fields("Cnt").Value)
    rs.Close
    Exit Function

ErrorHandler:
    LogError "modDatabase.GetLowStockCount", Err.Number, Err.Description
    GetLowStockCount = 0
End Function

Private Sub CreateTables()
    On Error GoTo ErrorHandler
    
    Dim SQL As String
    
    SQL = "CREATE TABLE Products (" & _
          "ProductID COUNTER PRIMARY KEY, " & _
          "SKU TEXT(15) NOT NULL, " & _
          "ProductName TEXT(100) NOT NULL, " & _
          "Category TEXT(50) NOT NULL, " & _
          "Price CURRENCY NOT NULL, " & _
          "Quantity INTEGER NOT NULL, " & _
          "ReorderLevel INTEGER NOT NULL)"
    
    g_Connection.Execute SQL
    
    SQL = "CREATE TABLE Users (" & _
          "UserID COUNTER PRIMARY KEY, " & _
          "Username TEXT(50) NOT NULL, " & _
          "PasswordHash TEXT(255) NOT NULL, " & _
          "Role TEXT(20) NOT NULL, " & _
          "FullName TEXT(100) NOT NULL)"
    
    g_Connection.Execute SQL
    
    LogMessage "Tables created successfully."
    Exit Sub

ErrorHandler:
    LogError "modDatabase.CreateTables", Err.Number, Err.Description
End Sub

Private Sub SeedUsers()
    On Error GoTo ErrorHandler
    
    Dim SQL As String
    
    SQL = "INSERT INTO Users (Username, PasswordHash, Role, FullName) VALUES " & _
          "('" & "admin" & "', '" & HashPassword("admin123") & "', '" & ROLE_ADMIN & "', 'System Administrator')"
    g_Connection.Execute SQL
    
    SQL = "INSERT INTO Users (Username, PasswordHash, Role, FullName) VALUES " & _
          "('" & "manager" & "', '" & HashPassword("manager123") & "', '" & ROLE_MANAGER & "', 'Store Manager')"
    g_Connection.Execute SQL
    
    SQL = "INSERT INTO Users (Username, PasswordHash, Role, FullName) VALUES " & _
          "('" & "clerk" & "', '" & HashPassword("clerk123") & "', '" & ROLE_SUPERVISOR & "', 'Store Clerk')"
    g_Connection.Execute SQL
    
    LogMessage "Users seeded successfully."
    Exit Sub

ErrorHandler:
    LogError "modDatabase.SeedUsers", Err.Number, Err.Description
End Sub

Private Sub SeedProducts()
    On Error GoTo ErrorHandler
    
    AddProduct "ELC-1001-0001", "Wireless Mouse", CAT_ELECTRONICS, 29.99, 150, 25
    AddProduct "ELC-1002-0002", "USB-C Hub", CAT_ELECTRONICS, 49.99, 8, 15
    AddProduct "CLT-2001-0001", "Cotton T-Shirt", CAT_CLOTHING, 19.99, 200, 30
    AddProduct "CLT-2002-0002", "Denim Jeans", CAT_CLOTHING, 45.99, 5, 20
    AddProduct "FOD-3001-0001", "Organic Coffee Beans", CAT_FOOD, 12.99, 300, 50
    AddProduct "FOD-3002-0002", "Green Tea Box", CAT_FOOD, 8.99, 0, 25
    AddProduct "FRN-4001-0001", "Office Desk", CAT_FURNITURE, 299.99, 12, 5
    AddProduct "FRN-4002-0002", "Ergonomic Chair", CAT_FURNITURE, 449.99, 3, 5
    AddProduct "OFS-5001-0001", "A4 Paper Ream", CAT_OFFICE_SUPPLIES, 5.99, 500, 100
    AddProduct "OTH-6001-0001", "First Aid Kit", CAT_OTHER, 24.99, 10, 10
    
    LogMessage "Products seeded successfully."
    Exit Sub

ErrorHandler:
    LogError "modDatabase.SeedProducts", Err.Number, Err.Description
End Sub

Public Sub Main()
    InitializeDatabase
    frmLogin.Show vbModal
End Sub
