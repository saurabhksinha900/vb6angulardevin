VERSION 5.00
Begin VB.Form frmLogin 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "VB6 Inventory Management System - Login"
   ClientHeight    =   4200
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   5400
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4200
   ScaleWidth      =   5400
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdExit 
      Cancel          =   -1  'True
      Caption         =   "E&xit"
      Height          =   495
      Left            =   2880
      TabIndex        =   4
      Top             =   3120
      Width           =   1575
   End
   Begin VB.CommandButton cmdLogin 
      Caption         =   "&Login"
      Default         =   -1  'True
      Height          =   495
      Left            =   960
      TabIndex        =   3
      Top             =   3120
      Width           =   1575
   End
   Begin VB.TextBox txtPassword 
      Height          =   375
      IMEMode         =   3  'DISABLE
      Left            =   1920
      MaxLength       =   50
      PasswordChar    =   "*"
      TabIndex        =   2
      Top             =   2400
      Width           =   2535
   End
   Begin VB.TextBox txtUsername 
      Height          =   375
      Left            =   1920
      MaxLength       =   50
      TabIndex        =   1
      Top             =   1800
      Width           =   2535
   End
   Begin VB.Label lblStatus 
      Alignment       =   2  'Center
      Caption         =   "Please enter your credentials"
      ForeColor       =   &H00800000&
      Height          =   375
      Left            =   240
      TabIndex        =   7
      Top             =   3720
      Width           =   4935
   End
   Begin VB.Label lblPassword 
      Caption         =   "Password:"
      Height          =   255
      Left            =   840
      TabIndex        =   6
      Top             =   2460
      Width           =   975
   End
   Begin VB.Label lblUsername 
      Caption         =   "Username:"
      Height          =   255
      Left            =   840
      TabIndex        =   5
      Top             =   1860
      Width           =   975
   End
   Begin VB.Label lblTitle 
      Alignment       =   2  'Center
      Caption         =   "VB6 Inventory Management System"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   0
      Top             =   360
      Width           =   4935
   End
   Begin VB.Label lblVersion 
      Alignment       =   2  'Center
      Caption         =   "Version 1.0.0"
      Height          =   255
      Left            =   240
      TabIndex        =   8
      Top             =   960
      Width           =   4935
   End
End
Attribute VB_Name = "frmLogin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_LoginAttempts As Integer

Private Sub Form_Load()
    m_LoginAttempts = 0
    lblTitle.Caption = APP_NAME
    lblVersion.Caption = "Version " & APP_VERSION
    lblStatus.Caption = "Please enter your credentials"
    txtUsername.Text = ""
    txtPassword.Text = ""
    txtUsername.SetFocus
End Sub

Private Sub cmdLogin_Click()
    On Error GoTo ErrorHandler
    
    Dim Username As String
    Dim Password As String
    
    Username = Trim$(txtUsername.Text)
    Password = txtPassword.Text
    
    If Len(Username) = 0 Then
        lblStatus.Caption = "Please enter a username."
        txtUsername.SetFocus
        Exit Sub
    End If
    
    If Len(Password) = 0 Then
        lblStatus.Caption = "Please enter a password."
        txtPassword.SetFocus
        Exit Sub
    End If
    
    Set g_CurrentUser = New clsUser
    
    If g_CurrentUser.Authenticate(Username, Password) Then
        LogMessage "Login successful for user: " & Username
        Unload Me
        frmMain.Show
    Else
        m_LoginAttempts = m_LoginAttempts + 1
        Dim RemainingAttempts As Integer
        RemainingAttempts = MAX_LOGIN_ATTEMPTS - m_LoginAttempts
        
        If RemainingAttempts <= 0 Then
            LogMessage "Account locked after " & MAX_LOGIN_ATTEMPTS & " failed attempts for user: " & Username
            MsgBox "Maximum login attempts exceeded. The application will now close.", vbCritical, APP_NAME
            CloseConnection
            End
        Else
            lblStatus.Caption = "Invalid credentials. " & RemainingAttempts & " attempt(s) remaining."
            txtPassword.Text = ""
            txtPassword.SetFocus
        End If
    End If
    
    Exit Sub

ErrorHandler:
    LogError "frmLogin.cmdLogin_Click", Err.Number, Err.Description
    MsgBox "An error occurred during login: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub cmdExit_Click()
    CloseConnection
    End
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' Allow unload
End Sub
