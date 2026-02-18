VERSION 5.00
Begin VB.Form frmReport 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Inventory Reports"
   ClientHeight    =   7200
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   7800
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7200
   ScaleWidth      =   7800
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdClose 
      Cancel          =   -1  'True
      Caption         =   "&Close"
      Height          =   495
      Left            =   5880
      TabIndex        =   8
      Top             =   6480
      Width           =   1575
   End
   Begin VB.CommandButton cmdExport 
      Caption         =   "&Export"
      Height          =   495
      Left            =   4200
      TabIndex        =   7
      Top             =   6480
      Width           =   1575
   End
   Begin VB.TextBox txtReport 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4335
      Left            =   240
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   6
      Top             =   1920
      Width           =   7335
   End
   Begin VB.CommandButton cmdGenerate 
      Caption         =   "&Generate"
      Default         =   -1  'True
      Height          =   495
      Left            =   5520
      TabIndex        =   5
      Top             =   720
      Width           =   1575
   End
   Begin VB.Frame fraReportType 
      Caption         =   "Report Type"
      Height          =   1455
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   4935
      Begin VB.OptionButton optValue 
         Caption         =   "Inventory Value Report"
         Height          =   255
         Left            =   2520
         TabIndex        =   4
         Top             =   960
         Width           =   2175
      End
      Begin VB.OptionButton optLowStock 
         Caption         =   "Low Stock Alert Report"
         Height          =   255
         Left            =   2520
         TabIndex        =   3
         Top             =   480
         Width           =   2175
      End
      Begin VB.OptionButton optByCategory 
         Caption         =   "By Category Report"
         Height          =   255
         Left            =   240
         TabIndex        =   2
         Top             =   960
         Width           =   2055
      End
      Begin VB.OptionButton optSummary 
         Caption         =   "Summary Report"
         Height          =   255
         Left            =   240
         TabIndex        =   1
         Top             =   480
         Value           =   -1  'True
         Width           =   2055
      End
   End
   Begin VB.Label lblReportOutput 
      Caption         =   "Report Output:"
      Height          =   255
      Left            =   240
      TabIndex        =   9
      Top             =   1680
      Width           =   1575
   End
End
Attribute VB_Name = "frmReport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_Inventory As clsInventory
Private m_CurrentReportType As Integer

Private Sub Form_Load()
    Set m_Inventory = New clsInventory
    optSummary.Value = True
    m_CurrentReportType = RPT_SUMMARY
    txtReport.Text = ""
    cmdExport.Enabled = False
End Sub

Private Sub cmdGenerate_Click()
    On Error GoTo ErrorHandler
    
    Dim ReportText As String
    
    If optSummary.Value Then
        m_CurrentReportType = RPT_SUMMARY
        ReportText = m_Inventory.GetSummaryReport()
    ElseIf optByCategory.Value Then
        m_CurrentReportType = RPT_BY_CATEGORY
        ReportText = m_Inventory.GetCategoryReport()
    ElseIf optLowStock.Value Then
        m_CurrentReportType = RPT_LOW_STOCK
        ReportText = m_Inventory.GetLowStockReport()
    ElseIf optValue.Value Then
        m_CurrentReportType = RPT_INVENTORY_VALUE
        ReportText = m_Inventory.GetValueReport()
    End If
    
    txtReport.Text = ReportText
    cmdExport.Enabled = (Len(ReportText) > 0)
    
    Exit Sub

ErrorHandler:
    LogError "frmReport.cmdGenerate_Click", Err.Number, Err.Description
    MsgBox "Error generating report: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub cmdExport_Click()
    On Error GoTo ErrorHandler
    
    If Len(txtReport.Text) = 0 Then
        MsgBox "No report to export. Please generate a report first.", vbInformation, APP_NAME
        Exit Sub
    End If
    
    Dim ReportTypeName As String
    Select Case m_CurrentReportType
        Case RPT_SUMMARY: ReportTypeName = "Summary"
        Case RPT_BY_CATEGORY: ReportTypeName = "ByCategory"
        Case RPT_LOW_STOCK: ReportTypeName = "LowStock"
        Case RPT_INVENTORY_VALUE: ReportTypeName = "InventoryValue"
        Case Else: ReportTypeName = "Report"
    End Select
    
    Dim DefaultFileName As String
    DefaultFileName = "Report_" & ReportTypeName & "_" & FormatDate_Custom(Now) & ".txt"
    
    Dim FilePath As String
    FilePath = InputBox("Enter file path to save the report:", APP_NAME, App.Path & "\" & DefaultFileName)
    
    If Len(FilePath) = 0 Then Exit Sub
    
    Dim FileNum As Integer
    FileNum = FreeFile
    Open FilePath For Output As #FileNum
    Print #FileNum, txtReport.Text
    Close #FileNum
    
    MsgBox "Report exported successfully to:" & vbCrLf & FilePath, vbInformation, APP_NAME
    LogMessage "Report exported: " & FilePath
    
    Exit Sub

ErrorHandler:
    LogError "frmReport.cmdExport_Click", Err.Number, Err.Description
    MsgBox "Error exporting report: " & Err.Description, vbExclamation, APP_NAME
End Sub

Private Sub cmdClose_Click()
    Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set m_Inventory = Nothing
End Sub
