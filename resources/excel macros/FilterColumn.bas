' Generated using ChatGPT
Sub FilterColumn()
    Dim FilterValue As String

    ' Prompt the user for the filter value
    FilterValue = InputBox("Enter the value to filter:")

    ' Check if the user entered a value
    If FilterValue <> "" Then
        ' Apply the filter to column A (change the column letter as needed)
        Columns("A:A").AutoFilter Field:=1, Criteria1:=FilterValue
    Else
        ' If the user did not enter a value, remove the filter
        ActiveSheet.AutoFilterMode = False
    End If
End Sub

Sub FilterForManyValuesInColumn()
    Dim FilterValue As String
    Dim FilterValues() As String

    ' Prompt the user for the filter values
    FilterValue = InputBox("Enter the values to filter (comma-separated):")

    ' Check if the user entered any values
    If FilterValue <> "" Then
        ' Split the filter values into an array
        FilterValues = Split(FilterValue, ",")

        ' Apply the filter to column A (change the column letter as needed)
        Columns("K:K").AutoFilter Field:=1, Criteria1:=FilterValues, Operator:=xlFilterValues
    Else
        ' If the user did not enter any values, remove the filter
        ActiveSheet.AutoFilterMode = False
    End If
End Sub