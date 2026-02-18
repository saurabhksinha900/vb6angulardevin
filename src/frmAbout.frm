VERSION 5.00
Begin VB.Form frmAbout 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "About"
   ClientHeight    =   3600
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   5100
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3600
   ScaleWidth      =   5100
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   495
      Left            =   1800
      TabIndex        =   0
      Top             =   2880
      Width           =   1575
   End
   Begin VB.Label lblCopyright 
      Alignment       =   2  'Center
      Caption         =   "Copyright"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   2400
      Width           =   4620
   End
   Begin VB.Label lblDeveloper 
      Alignment       =   2  'Center
      Caption         =   "Developer"
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   2040
      Width           =   4620
   End
   Begin VB.Label lblDescription 
      Alignment       =   2  'Center
      Caption         =   "Description"
      Height          =   495
      Left            =   240
      TabIndex        =   3
      Top             =   1320
      Width           =   4620
      WordWrap        =   -1  'True
   End
   Begin VB.Label lblVersion 
      Alignment       =   2  'Center
      Caption         =   "Version"
      Height          =   255
      Left            =   240
      TabIndex        =   2
      Top             =   960
      Width           =   4620
   End
   Begin VB.Label lblAppName 
      Alignment       =   2  'Center
      Caption         =   "App Name"
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
      TabIndex        =   1
      Top             =   360
      Width           =   4620
   End
End
Attribute VB_Name = "frmAbout"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
    lblAppName.Caption = APP_NAME
    lblVersion.Caption = "Version " & APP_VERSION
    lblDescription.Caption = APP_DESCRIPTION
    lblDeveloper.Caption = "Developer: " & APP_DEVELOPER
    lblCopyright.Caption = APP_COPYRIGHT
End Sub

Private Sub cmdOK_Click()
    Unload Me
End Sub
