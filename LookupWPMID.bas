Attribute VB_Name = "Lookup"
Sub LookupValue()
Attribute LookupValue.VB_ProcData.VB_Invoke_Func = "H\n14"
    Dim searchValue As String
    Dim resultValue As Variant
    searchValue = Trim(Application.InputBox("Enter value to look up", "Lookup Value", Type:=2))
    If searchValue = "False" Then
        Exit Sub
    End If
    resultValue = Application.VLookup(searchValue, Range("A:B"), 2, False)
    If IsError(resultValue) Then
        Range("F10").Copy
    Else
        Range("F6").Value = "'" & resultValue ' Place the result in a temporary cell
        Range("F6").Copy ' Copy the value to the clipboard
        ' MsgBox "Result copied to clipboard: " & resultValue
    End If
End Sub
