Attribute VB_Name = "Lookup"
Sub LookupFDMID()
Attribute LookupValue.VB_ProcData.VB_Invoke_Func = "H\n14"
    Dim searchValue As String
    Dim resultValue As Variant
    searchValue = Trim(Application.InputBox("Enter value to look up", "Lookup Value", Type:=2))
    If searchValue = "False" Then
        Exit Sub
    End If
    resultValue = Application.VLookup(searchValue, Range("A:B"), 2, False)
    If IsError(resultValue) Then
        Range("G10").Copy
    Else
        Range("G6").Value = "'" & resultValue ' Place the result in a temporary cell
        Range("G6").Copy ' Copy the value to the clipboard
        ' MsgBox "Result copied to clipboard: " & resultValue
    End If
End Sub

Sub LookupConversionCase()
Attribute LookupCase.VB_ProcData.VB_Invoke_Func = "L\n14"
    Dim searchValue As String
    Dim resultValue As Variant
    searchValue = Trim(Application.InputBox("Enter value to look up", "Lookup Case", Type:=2))
    If searchValue = "False" Then
        Exit Sub
    End If
    resultValue = Application.VLookup(searchValue, Range("A:C"), 3, False)
     If IsError(resultValue) Then
        Range("G10").Copy
    Else
        Range("G6").Value = resultValue ' Place the result in a temporary cell
        Range("G6").Copy ' Copy the value to the clipboard
        ' MsgBox "Result copied to clipboard: " & resultValue
    End If
End Sub

Sub LookupAccount()
Attribute LookupAccount.VB_ProcData.VB_Invoke_Func = "K\n14"
    Dim searchValue As String
    Dim resultValue As Variant
    searchValue = Trim(Application.InputBox("Enter value to look up", "Lookup Account", Type:=2))
    If searchValue = "False" Then
        Exit Sub
    End If
    resultValue = Application.VLookup(searchValue, Range("A:D"), 4, False)
     If IsError(resultValue) Then
        Range("G10").Copy
    Else
        Range("G6").Value = resultValue ' Place the result in a temporary cell
        Range("G6").Copy ' Copy the value to the clipboard
        ' MsgBox "Result copied to clipboard: " & resultValue
    End If
End Sub

Function Clipboard$(Optional s$)
    Dim v: v = s  'Cast to variant for 64-bit VBA support
    With CreateObject("htmlfile")
    With .parentWindow.clipboardData
        Select Case True
            Case Len(s): .setData "text", v
            Case Else:   Clipboard = .GetData("text")
        End Select
    End With
    End With
End Function
