' Generated with ChatGPT
Sub SaveAsPDF()
    Dim filePath As Variant
    Dim FileName As String

    ' Prompt the user to save the workbook
    filePath = Application.GetSaveAsFilename(FileFilter:="PDF Files (*.pdf), *.pdf")

    ' Check if the user canceled the save dialog
    If filePath = False Then
        Exit Sub
    End If

    ' Set the file name based on the selected file path
    FileName = Dir(filePath)

    ' Print the active sheet to PDF
    ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, _
        FileName:=filePath, Quality:=xlQualityMinimum, _
        IncludeDocProperties:=False, IgnorePrintAreas:=False

End Sub

' Created with the help of ChatGPT
' To get the Forms library, look here https://stackoverflow.com/questions/35664768/cant-find-microsoft-forms-2-0-object-library-or-fm20-dll
Sub DefaultPDFSave()
    Dim filePath As Variant
    Dim dataObj As MSForms.DataObject
    Dim text As String
    
    Set dataObj = New MSForms.DataObject
    
    On Error Resume Next
    dataObj.GetFromClipboard
    text = dataObj.GetText
    On Error GoTo 0

    ' Set the relative default save location for the PDF
    Dim defaultPath As String
    defaultPath = ThisWorkbook.Path

    ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, _
        FileName:=defaultPath & "\" & text, Quality:=xlQualityMinimum, _
        IncludeDocProperties:=False, IgnorePrintAreas:=False
End Sub