Attribute VB_Name = "modConstants"
Option Explicit

' Application Info
Public Const APP_NAME As String = "VB6 Inventory Management System"
Public Const APP_VERSION As String = "1.0.0"
Public Const APP_DEVELOPER As String = "VB6 Development Team"
Public Const APP_COPYRIGHT As String = "Copyright (c) 2024"
Public Const APP_DESCRIPTION As String = "A comprehensive inventory management solution built with Visual Basic 6.0"

' Database
Public Const DB_PROVIDER As String = "Microsoft.Jet.OLEDB.4.0"
Public Const DB_DATA_SOURCE As String = ""

' Login
Public Const MAX_LOGIN_ATTEMPTS As Integer = 3

' Validation
Public Const SKU_LENGTH As Integer = 14
Public Const SKU_PART1_LEN As Integer = 3
Public Const SKU_PART2_LEN As Integer = 4
Public Const SKU_PART3_LEN As Integer = 4
Public Const PRODUCT_NAME_MAX As Integer = 100
Public Const PRICE_MIN As Currency = 0.01
Public Const PRICE_MAX As Currency = 999999.99
Public Const QTY_MIN As Long = 0
Public Const QTY_MAX As Long = 999999

' Categories
Public Const CAT_ALL As String = "(All)"
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

' Product Status
Public Const STATUS_OK As String = "OK"
Public Const STATUS_LOW_STOCK As String = "Low Stock"
Public Const STATUS_OUT_OF_STOCK As String = "Out of Stock"

' UI Colors
Public Const COLOR_LOW_STOCK As Long = &HC8FF& ' Orange (RGB 255,200,100) stored as BGR
Public Const COLOR_OUT_OF_STOCK As Long = &HB4B4FF ' Light Red (RGB 255,180,180) stored as BGR
Public Const COLOR_NORMAL As Long = &HFFFFFF ' White

' Report Types
Public Const RPT_SUMMARY As Integer = 1
Public Const RPT_BY_CATEGORY As Integer = 2
Public Const RPT_LOW_STOCK As Integer = 3
Public Const RPT_INVENTORY_VALUE As Integer = 4

' Log File
Public Const LOG_FILE_NAME As String = "InventoryManager.log"

' ListView Column Indices (0-based)
Public Const COL_ID As Integer = 0
Public Const COL_SKU As Integer = 1
Public Const COL_NAME As Integer = 2
Public Const COL_CATEGORY As Integer = 3
Public Const COL_PRICE As Integer = 4
Public Const COL_QTY As Integer = 5
Public Const COL_REORDER As Integer = 6
Public Const COL_TOTAL_VALUE As Integer = 7
Public Const COL_STATUS As Integer = 8

' Form Modes
Public Const MODE_ADD As Integer = 1
Public Const MODE_EDIT As Integer = 2

' Category Array Helper
Public Function GetCategories() As Variant
    GetCategories = Array(CAT_ELECTRONICS, CAT_CLOTHING, CAT_FOOD, CAT_FURNITURE, CAT_OFFICE_SUPPLIES, CAT_OTHER)
End Function
