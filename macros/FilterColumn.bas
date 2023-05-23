' Generated using ChatGPT
Sub FilterOneValueColumn()
    Dim FilterValue As String

    ' Prompt the user for the filter value
    FilterValue = InputBox("Enter the value to filter:")

    ' Check if the user entered a value
    If FilterValue <> "" Then
        ' Apply the filter to column A (change the column letter as needed)
        Columns("A:K").AutoFilter Field:=1, Criteria1:=FilterValue
    Else
        ' If the user did not enter a value, remove the filter
        ActiveSheet.AutoFilterMode = False
    End If
End Sub

' Function below created with the help of ChatGPT
Sub FilterColumn()
    Dim FilterValue As String
    Dim FeeCodes() As Variant
    Dim rngFiltered As Range
    Dim FirstCell As Range
    
    ' Prompt the user for the filter value
    FilterValue = InputBox("Enter the value to filter:")
    
    FeeCodes = FeeCodes = Array("164", "170", "800", "804", "10P", "10J", "10A", "10D", "018", "18E", "0AZ", "10Q", "10K", "10B", "10E", "001", "005", "015")
    
    ' Check if the user entered a value
    If FilterValue <> "" Then
    
        ' Apply the filter to column A (change the column letter as needed)
        ActiveSheet.Range("A:N").AutoFilter Field:=1, Criteria1:=FilterValue
        ActiveSheet.Range("A:N").AutoFilter Field:=11, Criteria1:=FeeCodes, Operator:=xlFilterValues
    
        ' Check if any visible cells are present after filtering
        On Error Resume Next
        Set rngFiltered = ActiveSheet.AutoFilter.Range.Offset(1, 0).SpecialCells(xlCellTypeVisible)
        'Set FirstCell = ActiveSheet.Range("A:N").Offset(1, 0).SpecialCells(xlCellTypeVisible)(1)
        On Error GoTo 0
        
        If rngFiltered Is Nothing Then
            ActiveSheet.AutoFilterMode = False
        Else
            ' Copy the cell value to the clipboard
            rngFiltered.Cells(1).Copy
            
            ' Display a message to indicate that the cell is copied
            MsgBox "Cell value has been copied to the clipboard."
        End If
        
    Else
        ' If the user did not enter a value, remove the filter
        ActiveSheet.AutoFilterMode = False
    End If
End Sub