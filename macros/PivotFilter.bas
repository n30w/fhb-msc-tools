Option Explicit

Sub Test()
    Dim pt As PivotTable
    Dim pf As PivotField
    Dim filterValue As String
    
    ' Set a reference to the pivot table
    Set pt = ThisWorkbook.ActiveSheet.PivotTables("fees")
    
    ' Set a reference to the pivot field you want to filter
    Set pf = pt.PivotFields("Outlet Number")
    
    ' Prompt the user to enter the filter value
    'filterValue = InputBox("Enter the filter value:")
    filterValue = "122160054880"
    
    ' Apply the filter to the pivot field
    pt.ClearAllFilters ' Clear any existing filters
    pf.PivotFilters.Add Type:=xlCaptionEquals, Value1:=filterValue ' Apply the filter
    
    ' Refresh the pivot table
    pt.RefreshTable
End Sub
