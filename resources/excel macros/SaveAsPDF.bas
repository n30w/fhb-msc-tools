' Generated using ChatGPT
Sub SaveAsPDF()
    Dim FilePath As Variant
    Dim FileName As String

    ' Prompt the user to save the workbook
    FilePath = Application.GetSaveAsFilename(FileFilter:="PDF Files (*.pdf), *.pdf")

    ' Check if the user canceled the save dialog
    If FilePath = False Then
        Exit Sub
    End If

    ' Set the file name based on the selected file path
    FileName = Dir(FilePath)

    ' Print the active sheet to PDF
    ActiveSheet.ExportAsFixedFormat Type:=xlTypePDF, _
        FileName:=FilePath, Quality:=xlQualityStandard, _
        IncludeDocProperties:=True, IgnorePrintAreas:=False

End Sub
