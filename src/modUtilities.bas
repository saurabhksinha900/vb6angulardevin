Attribute VB_Name = "modUtilities"
Option Explicit

Public Function IsValidSKU(ByVal SKU As String) As Boolean
    Dim Parts() As String
    Dim i As Integer
    Dim c As String
    
    If Len(SKU) <> SKU_LENGTH Then
        IsValidSKU = False
        Exit Function
    End If
    
    Parts = Split(SKU, "-")
    If UBound(Parts) <> 2 Then
        IsValidSKU = False
        Exit Function
    End If
    
    If Len(Parts(0)) <> SKU_PART1_LEN Or Len(Parts(1)) <> SKU_PART2_LEN Or Len(Parts(2)) <> SKU_PART3_LEN Then
        IsValidSKU = False
        Exit Function
    End If
    
    Dim FullStr As String
    FullStr = Parts(0) & Parts(1) & Parts(2)
    For i = 1 To Len(FullStr)
        c = Mid$(FullStr, i, 1)
        If Not (c >= "A" And c <= "Z") And Not (c >= "a" And c <= "z") And Not (c >= "0" And c <= "9") Then
            IsValidSKU = False
            Exit Function
        End If
    Next i
    
    IsValidSKU = True
End Function

Public Function IsValidPrice(ByVal PriceStr As String) As Boolean
    Dim Price As Double
    
    If Not IsNumeric(PriceStr) Then
        IsValidPrice = False
        Exit Function
    End If
    
    Price = CDbl(PriceStr)
    IsValidPrice = (Price >= PRICE_MIN And Price <= PRICE_MAX)
End Function

Public Function IsValidQuantity(ByVal QtyStr As String) As Boolean
    Dim Qty As Long
    
    If Not IsNumeric(QtyStr) Then
        IsValidQuantity = False
        Exit Function
    End If
    
    If InStr(QtyStr, ".") > 0 Then
        IsValidQuantity = False
        Exit Function
    End If
    
    Qty = CLng(QtyStr)
    IsValidQuantity = (Qty >= QTY_MIN And Qty <= QTY_MAX)
End Function

Public Function IsRequiredField(ByVal Value As String) As Boolean
    IsRequiredField = (Len(Trim$(Value)) > 0)
End Function

Public Function HashPassword(ByVal Password As String) As String
    Dim Hash As Long
    Dim i As Integer
    
    Hash = 5381
    For i = 1 To Len(Password)
        Hash = ((Hash * 33) Xor Asc(Mid$(Password, i, 1))) And &H7FFFFFFF
    Next i
    
    HashPassword = Hex$(Hash)
End Function

Public Function FormatAsCurrency(ByVal Amount As Currency) As String
    FormatAsCurrency = Format$(Amount, "$#,##0.00")
End Function

Public Function FormatAsInteger(ByVal Value As Long) As String
    FormatAsInteger = Format$(Value, "#,##0")
End Function

Public Function PadString(ByVal Text As String, ByVal Length As Long, Optional ByVal PadChar As String = " ") As String
    If Len(Text) >= Length Then
        PadString = Left$(Text, Length)
    Else
        PadString = Text & String$(Length - Len(Text), PadChar)
    End If
End Function

Public Function TruncateString(ByVal Text As String, ByVal MaxLength As Long) As String
    If Len(Text) <= MaxLength Then
        TruncateString = Text
    Else
        If MaxLength > 3 Then
            TruncateString = Left$(Text, MaxLength - 3) & "..."
        Else
            TruncateString = Left$(Text, MaxLength)
        End If
    End If
End Function

Public Sub LogMessage(ByVal Message As String)
    Dim FileNum As Integer
    
    On Error Resume Next
    FileNum = FreeFile
    Open App.Path & "\" & LOG_FILE_NAME For Append As #FileNum
    Print #FileNum, FormatDateTime_Custom(Now) & " [INFO] " & Message
    Close #FileNum
End Sub

Public Sub LogError(ByVal Source As String, ByVal ErrNumber As Long, ByVal ErrDescription As String)
    Dim FileNum As Integer
    
    On Error Resume Next
    FileNum = FreeFile
    Open App.Path & "\" & LOG_FILE_NAME For Append As #FileNum
    Print #FileNum, FormatDateTime_Custom(Now) & " [ERROR] " & Source & " - Error " & ErrNumber & ": " & ErrDescription
    Close #FileNum
End Sub

Public Function FormatDateTime_Custom(ByVal dt As Date) As String
    FormatDateTime_Custom = Format$(dt, "yyyy-mm-dd hh:nn:ss")
End Function

Public Function FormatDate_Custom(ByVal dt As Date) As String
    FormatDate_Custom = Format$(dt, "yyyy-mm-dd")
End Function

Public Function SafeString(ByVal Value As Variant) As String
    If IsNull(Value) Or IsEmpty(Value) Then
        SafeString = ""
    Else
        SafeString = CStr(Value)
    End If
End Function

Public Function SafeLong(ByVal Value As Variant) As Long
    If IsNull(Value) Or IsEmpty(Value) Then
        SafeLong = 0
    ElseIf IsNumeric(Value) Then
        SafeLong = CLng(Value)
    Else
        SafeLong = 0
    End If
End Function

Public Function SafeCurrency(ByVal Value As Variant) As Currency
    If IsNull(Value) Or IsEmpty(Value) Then
        SafeCurrency = 0
    ElseIf IsNumeric(Value) Then
        SafeCurrency = CCur(Value)
    Else
        SafeCurrency = 0
    End If
End Function

Public Function GetProductStatus(ByVal Quantity As Long, ByVal ReorderLevel As Long) As String
    If Quantity = 0 Then
        GetProductStatus = STATUS_OUT_OF_STOCK
    ElseIf Quantity <= ReorderLevel Then
        GetProductStatus = STATUS_LOW_STOCK
    Else
        GetProductStatus = STATUS_OK
    End If
End Function

Public Function EscapeSQL(ByVal Text As String) As String
    EscapeSQL = Replace(Text, "'", "''")
End Function

Public Function RepeatString(ByVal Text As String, ByVal Count As Long) As String
    Dim i As Long
    Dim Result As String
    Result = ""
    For i = 1 To Count
        Result = Result & Text
    Next i
    RepeatString = Result
End Function
