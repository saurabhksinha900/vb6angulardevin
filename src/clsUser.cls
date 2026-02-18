VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsUser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_UserID As Long
Private m_Username As String
Private m_Role As String
Private m_FullName As String

Public Property Get UserID() As Long
    UserID = m_UserID
End Property

Public Property Let UserID(ByVal Value As Long)
    m_UserID = Value
End Property

Public Property Get Username() As String
    Username = m_Username
End Property

Public Property Let Username(ByVal Value As String)
    m_Username = Value
End Property

Public Property Get Role() As String
    Role = m_Role
End Property

Public Property Let Role(ByVal Value As String)
    m_Role = Value
End Property

Public Property Get FullName() As String
    FullName = m_FullName
End Property

Public Property Let FullName(ByVal Value As String)
    m_FullName = Value
End Property

Public Property Get CanAddProduct() As Boolean
    CanAddProduct = (m_Role = ROLE_ADMIN Or m_Role = ROLE_MANAGER)
End Property

Public Property Get CanEditProduct() As Boolean
    CanEditProduct = (m_Role = ROLE_ADMIN Or m_Role = ROLE_MANAGER)
End Property

Public Property Get CanDeleteProduct() As Boolean
    CanDeleteProduct = (m_Role = ROLE_ADMIN)
End Property

Public Property Get CanGenerateReports() As Boolean
    CanGenerateReports = True
End Property

Public Property Get CanExportReports() As Boolean
    CanExportReports = True
End Property

Public Function Authenticate(ByVal Username As String, ByVal Password As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim rs As ADODB.Recordset
    Dim PwdHash As String
    
    PwdHash = HashPassword(Password)
    Set rs = AuthenticateUser(Username, PwdHash)
    
    If rs Is Nothing Then
        Authenticate = False
        Exit Function
    End If
    
    If rs.EOF Then
        Authenticate = False
        rs.Close
        Set rs = Nothing
        Exit Function
    End If
    
    m_UserID = SafeLong(rs.Fields("UserID").Value)
    m_Username = SafeString(rs.Fields("Username").Value)
    m_Role = SafeString(rs.Fields("Role").Value)
    m_FullName = SafeString(rs.Fields("FullName").Value)
    
    rs.Close
    Set rs = Nothing
    
    LogMessage "User authenticated: " & m_Username & " (" & m_Role & ")"
    Authenticate = True
    Exit Function

ErrorHandler:
    LogError "clsUser.Authenticate", Err.Number, Err.Description
    Authenticate = False
End Function

Public Sub LoadFromRecordset(ByVal rs As ADODB.Recordset)
    m_UserID = SafeLong(rs.Fields("UserID").Value)
    m_Username = SafeString(rs.Fields("Username").Value)
    m_Role = SafeString(rs.Fields("Role").Value)
    m_FullName = SafeString(rs.Fields("FullName").Value)
End Sub

Public Sub Clear()
    m_UserID = 0
    m_Username = ""
    m_Role = ""
    m_FullName = ""
End Sub

Private Sub Class_Initialize()
    Clear
End Sub
