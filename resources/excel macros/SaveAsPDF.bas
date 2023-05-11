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
Sub DefaultPDFSave()
    Dim filePath As Variant

    ' Set the relative default save location for the PDF
    Dim defaultPath As String
    defaultPath = ThisWorkbook.Path

    ' Prompt the user to specify the location to save the PDF
    'filePath = Application.GetSaveAsFilename(InitialFileName:=defaultPath & "FDMID code listing", FileFilter:="PDF Files (*.pdf), *.pdf")
    'ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, FileName:=filePath, Quality:=xlQualityStandard
        ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, _
        FileName:=defaultPath & "\FDMID code listing", Quality:=xlQualityMinimum, _
        IncludeDocProperties:=False, IgnorePrintAreas:=False
End Sub
